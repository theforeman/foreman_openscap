# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'
require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "foreman_plugin_template"
  gem.homepage = "http://github.com/isratrade/foreman_plugin_template"
  gem.license = "MIT"
  gem.summary = %Q{Plugin engine for Foreman }
  gem.description = %Q{Plugin engine for Foreman }
  gem.email = "name@example.com"
  gem.authors = ["Sample Name"]
  # dependencies defined in Gemfile
end

task :default => :test
