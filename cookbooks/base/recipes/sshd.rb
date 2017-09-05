
unless node[:no_sshd_config]

  allow_ssh_root_login_value = node.ssh[:allow_ssh_root_login] ? "yes" : "no"

  service "ssh" do
    supports :status => true, :restart => true, :reload => true
    action [ :enable, :start ]
    provider Chef::Provider::Service::Upstart if node.lsb.codename == "trusty"
  end

  execute "Configure sshd - allow root login" do
    user "root"
    command <<-EOF
    sed -i -e '/^PermitRootLogin.*/d' /etc/ssh/sshd_config
    echo "PermitRootLogin #{allow_ssh_root_login_value}" >> /etc/ssh/sshd_config
    EOF
    notifies :restart, "service[ssh]"
    not_if "egrep 'PermitRootLogin #{allow_ssh_root_login_value}' /etc/ssh/sshd_config"
  end

  execute "Configure sshd - disallow password" do
    user "root"
    command <<-EOF
    sed -i 's/^.*PasswordAuthentication yes\\s*$/PasswordAuthentication no/' /etc/ssh/sshd_config
    EOF
    notifies :restart, "service[ssh]"
    only_if "egrep 'PasswordAuthentication yes' /etc/ssh/sshd_config | grep -v 'KEEP IT'"
  end

  execute "Configure sshd - max startups" do
    user "root"
    command <<-EOF
    sed -i -e '/^MaxStartups.*/d' /etc/ssh/sshd_config
    echo "MaxStartups #{node.ssh[:max_startups]}" >> /etc/ssh/sshd_config
    EOF
    notifies :restart, "service[ssh]"
    not_if "egrep 'MaxStartups #{node.ssh[:max_startups]}' /etc/ssh/sshd_config"
  end

  use_dns_value = node.ssh[:use_dns] ? "yes" : "no"

  execute "Configure sshd - use dns" do
    user "root"
    command <<-EOF
    sed -i -e '/^UseDNS.*/d' /etc/ssh/sshd_config
    echo "UseDNS #{use_dns_value}" >> /etc/ssh/sshd_config
    EOF
    notifies :restart, "service[ssh]"
    not_if "egrep 'UseDNS #{use_dns_value}' /etc/ssh/sshd_config"
  end

  execute "Configure sshd - client alive interval" do
    user "root"
    command <<-EOF
    sed -i -e '/^ClientAliveInterval.*/d' /etc/ssh/sshd_config
    echo "ClientAliveInterval #{node.ssh[:client_alive_interval]}" >> /etc/ssh/sshd_config
    EOF
    notifies :restart, "service[ssh]"
    not_if "egrep 'ClientAliveInterval #{node.ssh[:client_alive_interval]}' /etc/ssh/sshd_config"
  end

  execute "Configure sshd - client alive count max" do
    user "root"
    command <<-EOF
    sed -i -e '/^ClientAliveCountMax.*/d' /etc/ssh/sshd_config
    echo "ClientAliveCountMax #{node.ssh[:client_alive_count_max]}" >> /etc/ssh/sshd_config
    EOF
    notifies :restart, "service[ssh]"
    not_if "egrep 'ClientAliveCountMax #{node.ssh[:client_alive_count_max]}' /etc/ssh/sshd_config"
  end

  gateway_ports_value = node.ssh[:gateway_ports] ? "yes" : "no"

  execute "Configure sshd - gateway ports" do
    user "root"
    command <<-EOF
    sed -i -e '/^GatewayPorts.*/d' /etc/ssh/sshd_config
    echo "GatewayPorts #{gateway_ports_value}" >> /etc/ssh/sshd_config
    EOF
    notifies :restart, "service[ssh]"
    not_if "egrep 'GatewayPorts #{gateway_ports_value}' /etc/ssh/sshd_config"
  end

  execute "Configure sshd - KexAlgorithms" do
    user "root"
    command <<-EOF
    sed '/KexAlgorithms*/d' -i /etc/ssh/sshd_config
    echo 'KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,\
diffie-hellman-group-exchange-sha256' >> /etc/ssh/sshd_config
    EOF
    notifies :restart, "service[ssh]"
    not_if "grep 'KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,\
diffie-hellman-group-exchange-sha256' /etc/ssh/sshd_config"
  end

  execute "Configure sshd - Ciphers" do
    user "root"
    command <<-EOF
    sed '/Ciphers*/d' -i /etc/ssh/sshd_config
    echo 'Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,\
aes192-ctr,aes128-ctr' >> /etc/ssh/sshd_config
    EOF
    notifies :restart, "service[ssh]"
    not_if "grep 'Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,\
aes192-ctr,aes128-ctr' /etc/ssh/sshd_config"
  end

  execute "Configure sshd - MACs" do
    user "root"
    command <<-EOF
    sed '/MACs*/d' -i /etc/ssh/sshd_config
    echo 'MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,\
hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com' >> /etc/ssh/sshd_config
    EOF
    notifies :restart, "service[ssh]"
    not_if "grep 'MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,\
hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com' /etc/ssh/sshd_config"
  end

end
