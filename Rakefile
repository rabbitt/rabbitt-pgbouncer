require 'bundler'
Bundler.require(:rake)

require 'puppet-syntax/tasks/puppet-syntax'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'

begin
  require 'puppet_blacksmith/rake_tasks'
rescue LoadError
end

PuppetLint.configuration.ignore_paths = ["spec/**/*.pp", "pkg/**/*.pp"]

desc "Validate manifests, templates, and ruby files"
task :validate do
  Dir['manifests/**/*.pp'].each do |manifest|
    sh "puppet parser validate --noop #{manifest}"
  end
  Dir['spec/**/*.rb','lib/**/*.rb'].each do |ruby_file|
    sh "ruby -c #{ruby_file}" unless ruby_file =~ /spec\/fixtures/
  end
  Dir['templates/**/*.erb'].each do |template|
    sh "erb -P -x -T '-' #{template} | ruby -c"
  end
end

Dir['lib/tasks/*.task'].each do |taskdef|
  load taskdef
end

# stop the rspec from cleaning each run
unless ENV['auto_clean']
  Rake::Task[:spec].clear
  desc "Run spec tests in a clean fixtures directory"
  task :spec do
    Rake::Task[:spec_prep].invoke
    Rake::Task[:spec_standalone].invoke
  end
end

task :default => :spec
