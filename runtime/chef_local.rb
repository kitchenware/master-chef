#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'tempfile'

server = ARGV[0]
localrolepath = ARGV[1]
user = "chef"

abort "Incorrect Syntax, you should use it like this : chef_local.rb servername localrolepath \n Locale role path is the folder containings your custom role and configuration override" unless ARGV.length == 2

puts "Running chef with local cookbooks : on #{user}@#{server} and local role path : #{localrolepath} "

def exec_local cmd
  begin
    abort "#{cmd} failed. Aborting..." unless system cmd
  rescue
    abort "#{cmd} failed. Aborting..."
  end
end
 
[File.join(File.dirname(__FILE__), "../../master-chef"), localrolepath].each do |dir|
  exec_local "rsync --delete -avh --exclude=.git #{dir}/ #{user}@#{server}:/tmp/#{File.basename(dir)}/"
end

exec_local "scp #{user}@#{server}:/etc/chef/local.json /tmp/"

json = ::JSON.parse(File.read(File.join("/tmp/", "local.json")))
json["repos"] = {:local_path => ["/tmp/master-chef" , "/tmp/chef-infra"]}
f = Tempfile.new 'local.json'
f.write JSON.pretty_generate(json)
f.close

exec_local "scp #{f.path}  #{user}@#{server}:/tmp/local.json"
exec_local "ssh #{user}@#{server} MASTER_CHEF_CONFIG=/tmp/local.json /etc/chef/rbenv_sudo_chef.sh -c /etc/chef/solo.rb"
 

