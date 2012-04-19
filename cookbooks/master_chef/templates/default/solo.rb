config_file = ENV['MASTER_CHEF_CONFIG']

raise "Please specify config file with env var MASTER_CHEF_CONFIG" unless config_file
raise "File not found #{config_file}" unless File.exists? config_file

config = JSON.load(File.read(config_file))

run_list = ["recipe[master_chef::init]"] + config["run_list"]
json_file = Tempfile.new "chef_config"
json_file.write JSON.dump({"run_list" => run_list})
json_file.close

ENV['MASTER_CHEF_CONFIG'] = File.expand_path(config_file)

def exec_local cmd
  begin
    abort "#{cmd} failed. Aborting..." unless system cmd
  rescue
    abort "#{cmd} failed. Aborting..."
  end
end

git_cache_directory = ENV["GIT_CACHE_DIRECTORY"] || "/var/chef/cache/git_repos"
exec_local "mkdir -p #{git_cache_directory}"

cookbooks = []
roles = []

if config["repos"]["git"]
  config["repos"]["git"].each do |url|
    name = File.basename(url)
    target = File.join(git_cache_directory, name)
    unless File.exists? target
      puts "Cloning git repo #{url}"
      exec_local "cd #{git_cache_directory} && git clone #{url} #{name} 2>&1"
    end
    exec_local "cd #{target} && git pull && echo `pwd` && git log -n1 | head -n1 | awk '{print $2}' 2>&1"
    cookbook = File.join(target, "cookbooks")
    cookbooks << cookbook if File.exists? cookbook
    role = File.join(target, "roles")
    roles << role if File.exists? role
  end
end

if config["repos"]["local_path"]
  config["repos"]["local_path"].each do |target|
    cookbook = File.join(target, "cookbooks")
    cookbooks << cookbook if File.exists? cookbook
    role = File.join(target, "roles")
    roles << role if File.exists? role
  end
end

puts "************************* Master chef SOLO *************************"
puts "Hostname : #{`hostname`}"
puts "Repos : #{config["repos"].inspect}"
puts "Run list : #{run_list.inspect}"
puts "Cookbooks path : #{cookbooks.inspect}"
puts "Roles path : #{roles.inspect}"
puts "********************************************************************"

log_level :info
log_location STDOUT
json_attribs json_file.path
cookbook_path cookbooks
role_path roles