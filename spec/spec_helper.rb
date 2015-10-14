require 'pathname'
require 'puppetlabs_spec_helper/module_spec_helper'
require 'fixtures/modules/module_data/lib/hiera/backend/module_data_backend.rb'

fixture_path = Pathname.new(File.expand_path(File.join(__FILE__, '..', 'fixtures')))

at_exit { RSpec::Puppet::Coverage.report! }

RSpec.configure do |c|
  # c.before(:each) do
  #   Puppet::Util::Log.level = :warning
  #   Puppet::Util::Log.newdestination(:console)
  # end

  c.module_path  = fixture_path.join('modules').to_s
  c.manifest_dir = fixture_path.join('manifests').to_s
  c.hiera_config = fixture_path.dirname.join('hiera', 'hiera.yaml').to_s
  c.default_facts = {
    :kernel          => 'Linux',
    :osfamily        => 'RedHat',
    :concat_basedir  => '/var/lib/puppet/concat',
  }
end

def pgb_db_fragment_key(opts={})
  opts.merge!({
    'client_dbname' => opts['client_dbname'] || opts['dbname'],
    'server_dbname' => opts['server_dbname'] || opts['client_dbname'] || opts['dbname'],
  })

  key_components = [
    'pgb_db_entry',
    opts['client_dbname'], opts['server_dbname'],
    opts['user'], opts['host'], opts['port'],
  ].compact.reject { |v| v =~ /^\s*$/ }

  Digest::MD5.hexdigest(key_components.join('_'))
end

def pgb_user_fragment_key(opts={})
  Digest::MD5.hexdigest("pgb_user_entry_#{opts['user'] || title}")
end

def password_hash(user, password)
  'md5' << Digest::MD5.hexdigest(password + user)
end

def with_param(type, setting, value, &block)
  context "with #{setting} => #{value}" do
    let(:params) {
      { type => { setting => value } }.tap do |p|
        case type
          when 'config' then
            p['config'] = {
              'config_file' => '/etc/pgbouncer/pgbouncer.ini'
            }.merge(p['config'])
          when 'databases' then
            p['databases'] = {
              'test' => { 'host' => 'db.example.net' }
            }.deep_merge!(p['databases'])

        end
      end
    }
    instance_eval(&block)
  end
end

def with_config_param(setting, value, &block)
  with_param('config', setting, value, &block)
end

def with_user_param(user, setting, value, &block)
  with_param('users', user, { setting => value }, &block)
end

def with_db_param(db, setting, value, &block)
  with_param('databases', db, { setting => value}, &block)
end

def valid_config_param(setting, value, test=nil)
  with_config_param(setting, value) do
    it {
      should contain_file(config['config_file'])
            .with_content(/^#{setting}\s*=\s*#{Regexp.escape(test || value.to_s)}/)
    }
  end
end

def invalid_config_param(setting, value)
  with_config_param(setting, value) do
    it do
      expect {
        should contain_file(config['config_file'])
      }.to raise_error(Puppet::Error)
    end
  end
end

def config
  params['config'] || { 'config_file' => '/etc/pgbouncer/pgbouncer.ini' }
end

shared_examples :manageable_resource do |resource_name, title|
  with_config_param("manage_#{resource_name}", true) do
    it { should send(:"contain_#{resource_name}", title) }
  end
  with_config_param("manage_#{resource_name}", false) do
    it { should_not send(:"contain_#{resource_name}", title) }
  end
end

shared_examples :custom_setting do |setting, valid, invalid|
  Array(valid).each do |value|
    valid_config_param(setting, value)
  end

  Array(invalid).each do |value|
    invalid_config_param(setting, value)
  end
end

shared_examples :comma_list_setting do |setting|
  valid_config_param(setting, %w[a b c], 'a,b,c')
  invalid_config_param(setting, 0xFF)
  invalid_config_param(setting, {'x' => 'y'})
end

shared_examples :boolean_setting do |setting|
  [true, false].each do |value|
    valid_config_param(setting, value, value ? '1' : '0')
  end
  [{'x' => 'y'}, 99.9, 'foobar', 'true', 'false', 'yes', 'no', 1, 0].each do |value|
    invalid_config_param(setting, value)
  end
end

shared_examples :path_setting do |setting|
  valid_config_param(setting, '/foo/bar/baz')
  invalid_config_param(setting, 'foo/bar')
  invalid_config_param(setting, 0xFF)
end

shared_examples :string_setting do |setting|
  valid_config_param(setting, 'foo')
  invalid_config_param(setting, {'x' => 'y'})
end

shared_examples :float_setting do |setting|
  valid_config_param(setting, rand(-0xFFFFFFFF.to_f..0xFFFFFFFF.to_f))
  invalid_config_param(setting, 'baz')
end

shared_examples :bounded_float_setting do |setting, min=nil, max=nil|
  valid_config_param(setting, (min || -0xFFFFFFFF.to_f))
  valid_config_param(setting, (max || 0xFFFFFFFF.to_f))
  valid_config_param(setting, rand( ((min || -0xFFFFFFFF.to_f)+1) .. ((max || 0xFFFFFFFF.to_f))-1))
  invalid_config_param(setting, min - 0.1) unless min.nil?
  invalid_config_param(setting, max + 0.1) unless max.nil?
end

shared_examples :integer_setting do |setting|
  valid_config_param(setting, rand(-0xFFFFFFFF..0xFFFFFFFF))
  invalid_config_param(setting, 'baz')
end

shared_examples :bounded_integer_setting do |setting, min=nil, max=nil|
  valid_config_param(setting, (min || -0xFFFFFFFF))
  valid_config_param(setting, (max || 0xFFFFFFFF))
  valid_config_param(setting, rand( ((min || 0x00)+1) .. ((max || 0xFFFFFFFF))-1))
  invalid_config_param(setting, min - 1) unless min.nil?
  invalid_config_param(setting, max + 1) unless max.nil?
end

shared_examples :enumerated_setting do |setting, options|
  Array(options).each do |value|
    valid_config_param(setting, value)
  end
  invalid_config_param(setting, ':__xx__:')
end