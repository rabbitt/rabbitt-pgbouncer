source 'https://rubygems.org'

group :rake, :test do
  gem 'puppetlabs_spec_helper', '>= 0.1.0'
  gem 'puppet-blacksmith',       :require => false
  # gem 'rspec-system-puppet',     :require => false
end

group :rake do
  gem 'rake',         '>= 10.1.0'
  gem 'rspec-puppet', '>= 2.0.0'
  gem 'mocha',        '> 0.13'
  gem 'puppet-lint',  '>= 1.0.1'
  gem 'puppet-syntax'
  gem 'deep_merge'
  gem 'metadata-json-lint'
  # gem 'rspec-system-serverspec', :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion
else
  gem 'puppet', '~> 3.7.1'
end

gem 'facter', '>= 1.7.0'
gem 'rabbitt-githooks', '~> 1.5.5'
