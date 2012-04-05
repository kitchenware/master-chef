
define :add_ssh_to_known_hosts, {
  :ssh_host => nil,
  :ssh_user => nil,
  } do

  add_ssh_to_known_hosts = params

  raise "Please specify ssh_host for add_ssh_to_known_hosts" unless add_ssh_to_known_hosts[:ssh_host]
  raise "Please specify ssh_user for add_ssh_to_known_hosts" unless add_ssh_to_known_hosts[:ssh_user]

  execute "Allow ssh connection to #{add_ssh_to_known_hosts[:ssh_host]} for #{add_ssh_to_known_hosts[:name]}" do
    user add_ssh_to_known_hosts[:name]
    command <<-EOH
    ssh -o StrictHostKeyChecking=no #{add_ssh_to_known_hosts[:ssh_user]}@#{add_ssh_to_known_hosts[:ssh_host]} 'echo' || true
    EOH
    not_if "ssh-keygen -F #{add_ssh_to_known_hosts[:ssh_host]} -f #{get_home add_ssh_to_known_hosts[:name]}/.ssh/known_hosts | grep #{add_ssh_to_known_hosts[:ssh_host]}"
  end

end