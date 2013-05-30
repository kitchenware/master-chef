require 'rubygems'
require "bundler/setup"

task :foodcritic do
  sh 'foodcritic cookbooks'
end

task :default => [:foodcritic]