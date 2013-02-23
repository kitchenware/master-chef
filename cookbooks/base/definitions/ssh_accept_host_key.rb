
define :ssh_accept_host_key, {
  :user => nil,
} do
  ssh_accept_host_key_params = params

  raise "Please specify user with ssh_accept_host_key" unless ssh_accept_host_key_params[:user]

  execute "accept key for #{ssh_accept_host_key_params[:name]}" do
    command "ssh -o StrictHostKeyChecking=no #{ssh_accept_host_key_params[:name]} exit || true"
    user ssh_accept_host_key_params[:user]
    not_if "ssh-keygen -F #{ssh_accept_host_key_params[:name]} -f #{get_home ssh_accept_host_key_params[:user]}/.ssh/known_hosts"
  end

end