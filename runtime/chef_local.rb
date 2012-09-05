#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'tempfile'

abort "Syntax : chef_local.rb host [additionnal chef cookbooks & roles path]" if ARGV == 0

Dir.chdir File.join(File.dirname(__FILE__), "..")

server = ARGV[0]
additionnal_path = ARGV[1]
user = "chef"

if additionnal_path
  puts "Running chef with local cookbooks : on #{user}@#{server} with additionnal_path #{additionnal_path}"
else
  puts "Running chef with local cookbooks : on #{user}@#{server} without additionnal_path"
end

def exec_local cmd
  begin
    abort "#{cmd} failed. Aborting..." unless system cmd
  rescue
    abort "#{cmd} failed. Aborting..."
  end
end

exec_local "scp #{user}@#{server}:/etc/chef/local.json /tmp/"

json = ::JSON.parse(File.read(File.join("/tmp/", "local.json")))
json["repos"] = {:local_path => []};
["../master-chef", additionnal_path].each do |dir|
  exec_local "rsync --delete -avh --exclude=.git #{dir}/ #{user}@#{server}:/tmp/#{File.basename(dir)}/" if dir
  json["repos"][:local_path].push("/tmp/#{File.basename(dir)}")
end
f = Tempfile.new 'local.json'
f.write JSON.pretty_generate(json)
f.close

envs = "MASTER_CHEF_CONFIG=/tmp/local.json"
envs += " http_proxy=http://#{ENV["PROXY"]}" if ENV["PROXY"]
exec_local "scp #{f.path} #{user}@#{server}:/tmp/local.json"
exec_local "ssh #{user}@#{server} #{envs} /etc/chef/rbenv_sudo_chef.sh -c /etc/chef/solo.rb"


