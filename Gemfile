source 'https://rubygems.org'

group :test do
  gem 'rake'
  gem 'deep_merge'
  gem 'puppet-lint'
  gem 'puppet-syntax'
  gem 'rspec-puppet', '~> 2.0'
  gem 'rspec-system-puppet'
  gem 'puppetlabs_spec_helper'
  gem 'metadata-json-lint'
  gem 'puppet', ENV['PUPPET_VERSION'] || '~> 3.7.0'
end

group :development do
  gem 'travis'
  gem 'travis-lint'
  gem 'puppet-blacksmith', require: false
  gem 'rabbitt-githooks', '~> 1.6.0', require: false
end
