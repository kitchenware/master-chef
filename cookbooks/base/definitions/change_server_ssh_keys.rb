
define :change_server_ssh_keys, {
} do

  change_server_ssh_keys_params = params

  ["ssh_host_dsa_key", "ssh_host_rsa_key"].each do |f|
    template "/etc/ssh/#{f}" do
      mode '0600'
      source f
      cookbook change_server_ssh_keys_params[:name]
      notifies :restart, "service[ssh]"
    end
  end

  ["ssh_host_dsa_key.pub", "ssh_host_rsa_key.pub"].each do |f|
    template "/etc/ssh/#{f}" do
      mode '0644'
      source f
      cookbook change_server_ssh_keys_params[:name]
      notifies :restart, "service[ssh]"
    end
  end

end