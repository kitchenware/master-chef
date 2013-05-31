require 'rubygems'
require "bundler/setup"

task :foodcritic do
  sh "foodcritic cookbooks | grep -vE 'FC0(11|15|19|23)'"
end

task :default => [:foodcritic]