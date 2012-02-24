
unless node[:no_sshd_config]

  if node[:allow_ssh_root_login]

     bash "Configure sshd - allow root login" do
      user "root"
      code <<-EOF
      sed -i 's/^PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
      /etc/init.d/ssh restart
      EOF
      only_if "egrep '^PermitRootLogin no' /etc/ssh/sshd_config"
    end

  else

    bash "Configure sshd - disallow root login" do
      user "root"
      code <<-EOF
      sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
      /etc/init.d/ssh restart
      EOF
      only_if "egrep '^PermitRootLogin yes' /etc/ssh/sshd_config"
    end

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
