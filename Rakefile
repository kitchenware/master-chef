require 'rubygems'
require "bundler/setup"

task :foodcritic do
  sh "foodcritic cookbooks | grep -vE '(FC011|FC015|FC023)'"
end

task :default => [:foodcritic]