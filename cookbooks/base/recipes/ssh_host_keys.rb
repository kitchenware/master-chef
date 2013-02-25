
if node[:ssh_accept_host_keys]

  node.ssh_accept_host_keys.each do |k, v|
    v.each do |h|
      ssh_accept_host_key h do
        user k
      end
    end
  end

end