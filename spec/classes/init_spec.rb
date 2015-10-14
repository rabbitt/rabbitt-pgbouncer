require 'spec_helper'

describe 'pgbouncer', :type => :class do
  let(:params) do
    {
      'users'     => { 'jdoe'       => { 'password' => 'jdoe' } },
      'databases' => { 'rspec_test' => { 'host' => 'db01.example.net' } }
    }
  end

  describe 'compiles successfully' do
    it { should compile.with_all_deps }
  end

  describe 'contains expected classes and relationships' do
    it { should contain_class('pgbouncer') }
    it {
      should contain_anchor('pgbouncer::begin')
            .that_comes_before('Class[pgbouncer::package]')
    }
    it {
      should contain_class('pgbouncer::package')
            .that_requires('Anchor[pgbouncer::begin]')
            .that_comes_before('Class[pgbouncer::config]')
    }
    it {
      should contain_class('pgbouncer::config')
            .that_requires('Class[pgbouncer::package]')
            .that_notifies('Class[pgbouncer::service]')
            .that_comes_before('Class[pgbouncer::service]')
    }
    it {
      should contain_class('pgbouncer::service')
            .that_requires('Class[pgbouncer::config]')
            .that_comes_before('Anchor[pgbouncer::end]')
    }
    it {
      should contain_anchor('pgbouncer::end')
            .that_requires('Class[pgbouncer::service]')
    }
    it { should contain_concat('/etc/pgbouncer/databases.ini') }
    it { should contain_concat('/etc/pgbouncer/userlist.txt') }
    it { should contain_package('pgbouncer').with_ensure('installed') }
    it {
      should contain_service('pgbouncer').with({
        'ensure' => 'running',
        'enable' => 'true',
      })
    }

    it {
      should contain_service('pgbouncer').that_subscribes_to([
        'File[/etc/pgbouncer/pgbouncer.ini]',
        'File[/etc/pgbouncer/databases.ini]',
        'File[/etc/pgbouncer/userlist.txt]',
      ])
    }
    it {
      user, data = params['users'].first
      should contain_pgbouncer__user(user).with(data)
    }
    it {
      dbname, data = params['databases'].first
      should contain_pgbouncer__database(dbname).with(data)
    }
  end

  describe 'contains expected files' do
    it { should contain_file('/etc/pgbouncer/pgbouncer.ini').
                with({
                  'owner' => 'root',
                  'group' => 'root',
                  'mode'  => '0644'
                })
    }
    it { should contain_file('/etc/pgbouncer/databases.ini').
                with({'replace' => 'true', 'ensure' => 'present'})
    }

    it { should contain_file('/etc/pgbouncer/userlist.txt') }
    it { should contain_concat__fragment('pgb_db_header') }
    it { should contain_concat__fragment('pgb_user_header') }
    it {
      dbname, data = params['databases'].first
      fragment_key = pgb_db_fragment_key(data.merge({'dbname' => dbname}))

      should contain_concat__fragment(fragment_key)
            .with_content(/^#{dbname}\s*=\s*/)

      data.each do |param, value|
        should contain_concat__fragment(fragment_key).
              with_content(/#{param}=#{Regexp.escape(value)}/)
      end
    }

    it {
      user, data   = params['users'].first
      fragment_key = pgb_user_fragment_key({'user' => user})
      should contain_concat__fragment(fragment_key)
            .with_content(/^#{user.inspect}\s*#{password_hash(user, data['password']).inspect}$/)
    }
  end

  describe "package" do
    it_behaves_like :manageable_resource, :package, 'pgbouncer'

    describe "parameters" do
      with_config_param('package_name', 'foo') do
        it { should contain_package('foo') }
      end

      with_config_param('package_ensure', '1.6.1-1') do
        it { should contain_package('pgbouncer').with_ensure('1.6.1-1') }
      end
    end
  end

  describe "service" do
    it_behaves_like :manageable_resource, :service, 'pgbouncer'
    describe "parameters" do

      [true, false, 'true', 'false', 'running', 'stopped'].each do |value|
        with_config_param('service_ensure', value) do
          it { should contain_service('pgbouncer').with_ensure(value) }
        end
      end

      with_config_param('service_ensure', 'bogus') do
        it do
          expect {
            should contain_service('pgbouncer').with_ensure('bogus')
          }.to raise_error(Puppet::Error)
        end
      end

      [ true, false, 'true', 'false', 'manual', 'mask'].each do |value|
        with_config_param('service_enable', value) do
          it { should contain_service('pgbouncer').with_enable(value) }
        end
      end

      with_config_param('service_enable', 'bogus') do
        it do
          expect {
            should contain_service('pgbouncer').with_enable('bogus')
          }.to raise_error(Puppet::Error)
        end
      end
    end
  end

  describe "database" do
    context "valid data" do
      {
          'server_dbname'      => 'example',
          'client_dbname'      => 'example',
          'host'               => 'example.com',
          'port'               => 5432,
          'user'               => 'jdoe',
          'password'           => 'foobarbaz',
          'auth_user'          => 'jdoe',
          'pool_size'          => 1,
          'connect_query'      => 'SELECT 1',
          'pool_mode'          => 'session',
          'max_db_connections' => 1,
          'client_encoding'    => 'UTF8',
          'datestyle'          => 'ISO',
          'timezone'           => 'US/Eastern',
      }.each { |param, value|
        option_test = case param
          when /server_dbname/ then
            /dbname=#{value}/
          when /client_dbname/ then
            /^#{value}\s*=/
        else
          if value.to_s.include?(' ')
            /#{param}=#{value.inspect}/
          else
            /#{param}=#{value}/
          end
        end

        with_db_param('test', param, value) do
          it {
            dbname, data = params['databases'].first
            fragment_key = pgb_db_fragment_key(data.merge({'dbname' => dbname}))
            should contain_pgbouncer__database('test').with(data)
            should contain_concat__fragment(fragment_key)
                  .with_content(option_test)
          }
        end
      }
    end

    context "invalid data" do
      {
        'server_dbname'      => [
          { value: {'x' => 'x'}, match: /not a string/i },
          { value: 'rspec-test', match: /invalid database name/i },
          { value: 'foo.bar', match: /invalid database name/i },
        ],
        'client_dbname'      => [
          { value: {'x' => 'x'}, match: /not a string/i },
          { value: 'rspec-test', match: /invalid database name/i },
          { value: 'foo.bar', match: /invalid database name/i },
        ],
        'host'               => [
          { value: {'x' => 'x'}, match: /not a string/i },
          { value: 0, match: /expected a value that looks like a hostname or ip/ },
        ],
        'port'               => [
          { value: {'x' => 'x'}, match: /Expected first argument to be an Integer or Array/i },
          { value: 'foo', match: /Expected first argument to be an Integer or Array/ },
          { value: -1, match: /Expected -1 to be greater or equal to 1025/ },
          { value: 1, match: /Expected 1 to be greater or equal to 1025/ },
          { value: 1023, match: /Expected 1023 to be greater or equal to 1025/ },
          { value: 0x10000, match: /Expected 65536 to be smaller or equal to 65535/ },
        ],
        'user'               => [
          { value: {'x' => 'x'}, match: /not a string/i },
        ],
        'password'           => [
          { value: {'x' => 'x'}, match: /not a string/i },
        ],
        'auth_user'          => [
          { value: {'x' => 'x'}, match: /not a string/i },
        ],
        'pool_size'          => [
          { value: {'x' => 'x'}, match: /Expected first argument to be an Integer or Array/i },
          { value: 'foo', match: /Expected first argument to be an Integer or Array/ },
          { value: -1, match: /Expected -1 to be greater or equal to 1/ },
        ],
        'connect_query'      => [
          { value: {'x' => 'x'}, match: /not a string/i },
        ],
        'pool_mode'          => [
          { value: {'x' => 'x'}, match: /not a string/i },
          { value: 'foo', match: /expected one of statement, transaction or sesssion/ },
        ],
        'max_db_connections' => [
          { value: {'x' => 'x'}, match: /Expected first argument to be an Integer or Array/i },
          { value: 'x', match: /Expected first argument to be an Integer or Array/ },
          { value: -1, match: /Expected -1 to be greater or equal to 1/ },
        ],
        'client_encoding'    => [
          { value: {'x' => 'x'}, match: /not a string/i },
          { value: -1, match: /-1 is not a string/ },
        ],
        'datestyle'          => [
          { value: {'x' => 'x'}, match: /not a string/i },
          { value: -1, match: /-1 is not a string/ },
        ],
        'timezone'           => [
          { value: {'x' => 'x'}, match: /not a string/i },
          { value: -1, match: /-1 is not a string/ },
        ],
      }.each { |param, tests|
        tests.each do |test|
          with_db_param('test', param, test[:value]) do
            it { should compile.and_raise_error(test[:match]) }
          end
        end
      }
    end
  end

  describe "user data content" do
    context "valid data" do
      with_user_param('jdoe', 'password_hash', 'md512345678901234567890123456789012') do
        it {
          user, data   = params['users'].first
          fragment_key = pgb_user_fragment_key({'user' => user})
          should contain_pgbouncer__user('jdoe').with(data)
          should contain_concat__fragment(fragment_key)
                .with_content(/md512345678901234567890123456789012/)
        }
      end

      with_user_param('jdoe', 'password_hash', '12345678901234567890123456789012') do
        it {
          user, data   = params['users'].first
          fragment_key = pgb_user_fragment_key({'user' => user})
          should contain_pgbouncer__user('jdoe').with(data)
          should contain_concat__fragment(fragment_key)
                .with_content(/md512345678901234567890123456789012/)
        }
      end

      with_user_param('jdoe', 'password', 'abc123') do
        it {
          user, data   = params['users'].first
          fragment_key = pgb_user_fragment_key({'user' => user})
          password_hash = password_hash('jdoe', 'abc123')
          should contain_pgbouncer__user('jdoe').with(data)
          should contain_concat__fragment(fragment_key)
                .with_content(/#{password_hash}/)
        }
      end
    end

    context "invalid data" do
      with_param('users', 'jdoe', { 'password' => 'x', 'password_hash' => 'x'}) do
        it { should compile.and_raise_error(/password and password_hash are mutually exclusive/) }
      end
    end
  end

  describe "general parameters" do
    with_config_param('config_file', '/tmp/pgbouncer.ini') do
      it { should contain_file('/tmp/pgbouncer.ini') }
    end

    with_config_param('db_config_file', '/tmp/databases.ini') do
      it { should contain_file('/tmp/databases.ini') }
      it { should contain_concat('/tmp/databases.ini') }
    end

    with_config_param('auth_file', '/foo/bar/baz') do
      it { should contain_concat('/foo/bar/baz') }
    end

    it_behaves_like :path_setting, 'auth_file'
    it_behaves_like :path_setting, 'auth_hba_file'
    it_behaves_like :path_setting, 'pidfile'
    it_behaves_like :path_setting, 'logfile'
    it_behaves_like :path_setting, 'unix_socket_dir'
    it_behaves_like :custom_setting, 'listen_addr',  %w[192.168.1.1 *], %w[foo foo.bar.com 1]
    it_behaves_like :bounded_integer_setting, 'listen_port', 1025
    it_behaves_like :integer_setting, 'unix_socket_mode'
    it_behaves_like :string_setting, 'runtime_user'
    it_behaves_like :enumerated_setting, 'auth_type', %w[hba cert md5 plain trust any]
    it_behaves_like :string_setting, 'auth_query'
    it_behaves_like :enumerated_setting, 'pool_mode', %w[session transaction statement]
    it_behaves_like :bounded_integer_setting, 'max_client_conn', 0
    it_behaves_like :bounded_integer_setting, 'default_pool_size', 0
    it_behaves_like :bounded_integer_setting, 'min_pool_size', 0
    it_behaves_like :bounded_integer_setting, 'reserve_pool_size', 0
    it_behaves_like :bounded_float_setting, 'reserve_pool_timeout', 0.0
    it_behaves_like :bounded_integer_setting, 'max_db_connections', 0
    it_behaves_like :bounded_integer_setting, 'max_user_connections', 0
    it_behaves_like :boolean_setting, 'server_round_robin'
    it_behaves_like :comma_list_setting, 'ignore_startup_parameters'
    it_behaves_like :boolean_setting, 'disable_pqexec'
    it_behaves_like :boolean_setting, 'syslog'
    it_behaves_like :string_setting, 'syslog_ident'
    it_behaves_like :enumerated_setting, 'syslog_facility', %w[ auth authpriv daemon user local1 local2 local3 local4 local5 local6 local7 ]
    it_behaves_like :boolean_setting, 'log_connections'
    it_behaves_like :boolean_setting, 'log_disconnections'
    it_behaves_like :boolean_setting, 'log_pooler_errors'
    it_behaves_like :bounded_integer_setting, 'stats_period', 1
    it_behaves_like :bounded_integer_setting, 'verbose', 0, 2
    it_behaves_like :comma_list_setting, 'admin_users'
    it_behaves_like :comma_list_setting, 'stats_users'
    it_behaves_like :string_setting, 'server_reset_query'
    it_behaves_like :boolean_setting, 'server_reset_query_always'
    it_behaves_like :bounded_float_setting, 'server_check_delay', 0.0
    it_behaves_like :string_setting, 'server_check_query'
    it_behaves_like :bounded_float_setting, 'server_lifetime', 0.0
    it_behaves_like :bounded_float_setting, 'server_idle_timeout', 0.0
    it_behaves_like :bounded_float_setting, 'server_connect_timeout', 0.0
    it_behaves_like :bounded_float_setting, 'server_login_retry', 0.0
    it_behaves_like :bounded_float_setting, 'client_login_timeout', 0.0
    it_behaves_like :bounded_float_setting, 'autodb_idle_timeout', 0.0
    it_behaves_like :bounded_float_setting, 'dns_max_ttl', 0.0
    it_behaves_like :bounded_float_setting, 'dns_nxdomain_ttl', 0.0
    it_behaves_like :bounded_float_setting, 'dns_zone_check_period', 0.0
  end
end
