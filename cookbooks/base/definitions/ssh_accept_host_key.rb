
define :ssh_accept_host_key, {
  :user => nil,
  :port => 22,
} do

  ssh_accept_host_key_params = params

  raise "Please specify user with ssh_accept_host_key" unless ssh_accept_host_key_params[:user]

  host = ssh_accept_host_key_params[:name]
  host = host.split('@')[1] if host.match /@/

  ssh_keygen_host = host

  ssh_opts = "-o StrictHostKeyChecking=no "
  if ssh_accept_host_key_params[:port].to_s != "22"
    ssh_opts += "-p #{ssh_accept_host_key_params[:port]} "
    ssh_keygen_host = "[#{host}]:#{ssh_accept_host_key_params[:port]}"
  end

  execute "accept key for #{host} for user #{ssh_accept_host_key_params[:user]} port #{ssh_accept_host_key_params[:port]}" do
    command "ssh #{ssh_opts} #{host} exit || true"
    user ssh_accept_host_key_params[:user]
    not_if "ssh-keygen -F #{ssh_keygen_host} -f #{get_home ssh_accept_host_key_params[:user]}/.ssh/known_hosts | grep ."
  end

end