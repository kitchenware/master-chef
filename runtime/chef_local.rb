#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'tempfile'

abort "Syntax : chef_local.rb host [additionnal chef cookbooks & roles path]" if ARGV == 0

Dir.chdir File.join(File.dirname(__FILE__), "..")

server = ARGV[0]
additionnal_path = ARGV[1]
user = ENV['CHEF_USER'] || "chef"

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

git_cache_directory = ENV["GIT_CACHE_DIRECTORY"] || "/var/chef/cache/git_repos"
exec_local "ssh #{user}@#{server} sudo mkdir -p #{git_cache_directory}"

["../master-chef", additionnal_path].each do |dir|
  if dir
    target = "#{git_cache_directory}/local_#{File.basename(dir)}"
    exec_local "rsync --delete --rsync-path='sudo rsync' -rlptDv --chmod=go-rwx --exclude=.git #{dir}/ #{user}@#{server}:#{target}/"
    json["repos"][:local_path].push(target)
  end
end

f = Tempfile.new 'local.json'
f.write JSON.pretty_generate(json)
f.close

envs = "MASTER_CHEF_CONFIG=/tmp/local.json"
envs += " http_proxy=#{ENV["PROXY"]} https_proxy=#{ENV["PROXY"]}" if ENV["PROXY"]
envs += " CHEF_LOG_LEVEL=#{ENV["CHEF_LOG_LEVEL"]}" if ENV["CHEF_LOG_LEVEL"]
exec_local "scp #{f.path} #{user}@#{server}:/tmp/local.json"
exec_local "ssh #{user}@#{server} #{envs} /etc/chef/update.sh"
