
unless node[:no_sshd_config]

  allow_ssh_root_login_value = node.ssh[:allow_ssh_root_login] ? "yes" : "no"

  service "ssh" do
    supports :status => true, :restart => true, :reload => true
    action [ :enable, :start ]
  end

  execute "Configure sshd - allow root login" do
    user "root"
    command <<-EOF
    sed -i -e '/^PermitRootLogin.*/d' /etc/ssh/sshd_config
    echo "PermitRootLogin #{allow_ssh_root_login_value}" >> /etc/ssh/sshd_config
    EOF
    notifies :restart, "service[ssh]", :immediately
    not_if "egrep 'PermitRootLogin #{allow_ssh_root_login_value}' /etc/ssh/sshd_config"
  end

  execute "Configure sshd - disallow password" do
    user "root"
    command <<-EOF
    sed -i 's/^.*PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    EOF
    notifies :restart, "service[ssh]", :immediately
    only_if "egrep 'PasswordAuthentication yes' /etc/ssh/sshd_config"
  end

  execute "Configure sshd - max startups" do
    user "root"
    command <<-EOF
    sed -i -e '/^MaxStartups.*/d' /etc/ssh/sshd_config
    echo "MaxStartups #{node.ssh[:max_startups]}" >> /etc/ssh/sshd_config
    EOF
    notifies :restart, "service[ssh]", :immediately
    not_if "egrep 'MaxStartups #{node.ssh[:max_startups]}' /etc/ssh/sshd_config"
  end

  use_dns_value = node.ssh[:use_dns] ? "yes" : "no"

  execute "Configure sshd - use dns" do
    user "root"
    command <<-EOF
    sed -i -e '/^UseDNS.*/d' /etc/ssh/sshd_config
    echo "UseDNS #{use_dns_value}" >> /etc/ssh/sshd_config
    EOF
    notifies :restart, "service[ssh]", :immediately
    not_if "egrep 'UseDNS #{use_dns_value}' /etc/ssh/sshd_config"
  end

  execute "Configure sshd - client alive interval" do
    user "root"
    command <<-EOF
    sed -i -e '/^ClientAliveInterval.*/d' /etc/ssh/sshd_config
    echo "ClientAliveInterval #{node.ssh[:client_alive_interval]}" >> /etc/ssh/sshd_config
    EOF
    notifies :restart, "service[ssh]", :immediately
    not_if "egrep 'ClientAliveInterval #{node.ssh[:client_alive_interval]}' /etc/ssh/sshd_config"
  end

  execute "Configure sshd - client alive count max" do
    user "root"
    command <<-EOF
    sed -i -e '/^ClientAliveCountMax.*/d' /etc/ssh/sshd_config
    echo "ClientAliveCountMax #{node.ssh[:client_alive_count_max]}" >> /etc/ssh/sshd_config
    EOF
    notifies :restart, "service[ssh]", :immediately
    not_if "egrep 'ClientAliveCountMax #{node.ssh[:client_alive_count_max]}' /etc/ssh/sshd_config"
  end

  gateway_ports_value = node.ssh[:gateway_ports] ? "yes" : "no"

  execute "Configure sshd - gateway ports" do
    user "root"
    command <<-EOF
    sed -i -e '/^GatewayPorts.*/d' /etc/ssh/sshd_config
    echo "GatewayPorts #{gateway_ports_value}" >> /etc/ssh/sshd_config
    EOF
    notifies :restart, "service[ssh]", :immediately
    not_if "egrep 'GatewayPorts #{gateway_ports_value}' /etc/ssh/sshd_config"
  end

end
