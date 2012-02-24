
unless node[:no_sshd_config]
  
  bash "Configure sshd - disallow root login" do
    user "root"
    code <<-EOF
    sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
    /etc/init.d/ssh restart
    EOF
    only_if "egrep '^PermitRootLogin yes' /etc/ssh/sshd_config"
  end

  bash "Configure sshd - disallow password" do
    user "root"
    code <<-EOF
    sed -i 's/^.*PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    /etc/init.d/ssh restart
    EOF
    only_if "egrep 'PasswordAuthentication yes' /etc/ssh/sshd_config"
  end

end
