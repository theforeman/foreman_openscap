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
  gem.name = "foreman_radiator"
  gem.homepage = "http://github.com/isratrade/foreman_radiator"
  gem.license = "MIT"
  gem.summary = %Q{Plugin engine for Foreman to view radiator dashboard}
  gem.description = %Q{Plugin engine for Foreman to view radiator dashboard}
  gem.email = "jmagen@redhat.com"
  gem.authors = ["Joseph Mitchell Magen"]
  # dependencies defined in Gemfile
end

task :default => :test
