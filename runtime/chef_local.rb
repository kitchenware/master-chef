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

git_cache_directory = ENV["GIT_CACHE_DIRECTORY"]
if ENV["OMNIBUS"]
  local_json = "/opt/chef/etc/local.json"
  launch_cmd = "/opt/chef/bin/master-chef.sh"
  git_cache_directory = "/opt/chef/var/git_repos" unless git_cache_directory
  tmp_file = "/opt/chef/tmp/local.json"
else
  local_json = "/etc/chef/local.json"
  launch_cmd = "/etc/chef/update.sh"
  git_cache_directory = "/var/chef/cache/git_repos" unless git_cache_directory
  tmp_file = "/tmp/local.json"
end

local_tmp_file = Tempfile.new 'local_json'
local_tmp_file.close
local_tmp_file = local_tmp_file.path

exec_local "scp #{user}@#{server}:#{local_json} #{local_tmp_file}"

json = ::JSON.parse(File.read(local_tmp_file))
json["repos"] = {:local_path => []};

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

exec_local "scp #{f.path} #{user}@#{server}:#{tmp_file}"

envs = "MASTER_CHEF_CONFIG=#{tmp_file}"
envs += " http_proxy=#{ENV["PROXY"]} https_proxy=#{ENV["PROXY"]}" if ENV["PROXY"]
envs += " CHEF_LOG_LEVEL=#{ENV["CHEF_LOG_LEVEL"]}" if ENV["CHEF_LOG_LEVEL"]
exec_local "ssh #{user}@#{server} #{envs} #{launch_cmd}"
