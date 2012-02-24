config_file = ENV['MASTER_CHEF_CONFIG']

raise "Please specify config file with env var MASTER_CHEF_CONFIG" unless config_file
raise "File not found #{config_file}" unless File.exists? config_file

config = JSON.load(File.read(config_file))

run_list = ["recipe[master-chef::init]"] + config["run_list"]
json_file = Tempfile.new "chef_config"
json_file.write JSON.dump({"run_list" => run_list})
json_file.close

ENV['MASTER_CHEF_CONFIG'] = File.expand_path(config_file)

puts "************************* Master chef solo SOLO *************************"
puts "Hostname : #{`hostname`}"
puts "Repos : #{config["repos"]}"
puts "Run list : #{run_list.inspect}"
puts "******************************************************************************"

log_level :info
log_location STDOUT
json_attribs json_file.path
cookbook_path config["repos"]
role_path config["repos"].first + "/roles"
