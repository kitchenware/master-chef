
define :change_server_ssh_keys, {
} do

  change_server_ssh_keys_params = params

  service "ssh" do
    supports :status => true, :restart => true, :reload => true
    action [ :enable, :start ]
  end

  ["ssh_host_dsa_key", "ssh_host_rsa_key"].each do |f|
    template "/etc/ssh/#{f}" do
      mode 0600
      source f
      cookbook change_server_ssh_keys_params[:name]
      notifies :restart, resources(:service => "ssh")
    end
  end

  ["ssh_host_dsa_key.pub", "ssh_host_rsa_key.pub"].each do |f|
    template "/etc/ssh/#{f}" do
      mode 0644
      source f
      cookbook change_server_ssh_keys_params[:name]
      notifies :restart, resources(:service => "ssh")
    end
  end

end