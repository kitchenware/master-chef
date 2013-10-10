#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'tempfile'

abort "Syntax : chef_local.rb host [additionnal chef cookbooks & roles path]" if ARGV == 0

master_chef_path = File.expand_path(File.join(File.dirname(__FILE__), '..'))
master_chef_path += "/" unless master_chef_path.match(/\/$/)

Dir.chdir File.join(File.dirname(__FILE__), "..")

server = ARGV[0]
ARGV.shift
additionnal_paths = ARGV
user = ENV['CHEF_USER'] || "chef"

if additionnal_paths.empty?
  puts "Running chef with local cookbooks : on #{user}@#{server} without additionnal_paths"
else
  puts "Running chef with local cookbooks : on #{user}@#{server} with additionnal_paths #{additionnal_paths}"
end

def exec_local cmd
  begin
    abort "#{cmd} failed. Aborting..." unless system cmd
  rescue
    abort "#{cmd} failed. Aborting..."
  end
end

ssh_opts = ENV["SSH_OPTS"] || ""
ssh_opts += " -o StrictHostKeyChecking=no"

require 'tempfile'

unless ENV["NO_CONTROL_MASTER"]
  control_master_path = "/tmp/master_chef_socket_#{server}"

  Kernel.system("ssh -nNf -o StrictHostKeyChecking=no -o ControlMaster=yes -o ControlPath=\"#{control_master_path}\" #{user}@#{server}")
  Kernel.at_exit do
    Kernel.system("ssh -O exit -o StrictHostKeyChecking=no -o ControlPath=\"#{control_master_path}\" #{user}@#{server} 2> /dev/null")
    Kernel.system("rm -f #{control_master_path}")
  end
  ssh_opts += " -o ControlPath='#{control_master_path}'"
end

git_cache_directory = ENV["GIT_CACHE_DIRECTORY"]
local_json = "/opt/master-chef/etc/local.json"
launch_cmd = "/opt/master-chef/bin/master-chef.sh"
git_cache_directory = "/opt/master-chef/var/git_repos" unless git_cache_directory
tmp_file = "/opt/master-chef/tmp/local.json"

local_tmp_file = Tempfile.new 'local_json'
local_tmp_file.close
local_tmp_file = local_tmp_file.path

exec_local "scp #{ssh_opts} #{user}@#{server}:#{local_json} #{local_tmp_file}"

json = ::JSON.parse(File.read(local_tmp_file))
json["repos"] = {:local_path => []};

exec_local "ssh #{ssh_opts} #{user}@#{server} sudo mkdir -p #{git_cache_directory}"

repos = [master_chef_path]
repos += additionnal_paths
repos.each do |dir|
  if dir
    target = "#{git_cache_directory}/local_#{File.basename(dir)}"
    exec_local "rsync -e \"ssh #{ssh_opts}\" --delete --rsync-path='sudo rsync' -rlptDv --chmod=go-rwx --exclude=.git --exclude=runtime/sockets #{dir}/ #{user}@#{server}:#{target}/"
    json["repos"][:local_path].push(target)
  end
end

f = Tempfile.new 'local.json'
f.write JSON.pretty_generate(json)
f.close

exec_local "scp #{ssh_opts} #{f.path} #{user}@#{server}:#{tmp_file}"

envs = "MASTER_CHEF_CONFIG=#{tmp_file}"
envs += " http_proxy=#{ENV["PROXY"]} https_proxy=#{ENV["PROXY"]}" if ENV["PROXY"]
envs += " CHEF_LOG_LEVEL=#{ENV["CHEF_LOG_LEVEL"]}" if ENV["CHEF_LOG_LEVEL"]
exec_local "ssh #{ssh_opts} #{user}@#{server} #{envs} #{launch_cmd}"
