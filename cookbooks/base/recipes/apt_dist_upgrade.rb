
if node['platform'] == "ubuntu" || node['platform'] == "debian"

  if node.apt[:force_dist_upgrade]

    execute "apt-get dist-upgrade -y"

  end

end