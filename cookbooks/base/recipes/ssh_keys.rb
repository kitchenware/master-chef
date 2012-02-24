
if node[:ssh_keys]

  node.ssh_keys.each do |keys|

    keys["users"].each do |user|
      home = get_home user

      directory "#{home}/.ssh" do
        owner user
        mode 0700
      end

      template "#{home}/.ssh/authorized_keys" do
        owner user
        mode 0700
        variables :keys => keys["keys"]
        source "authorized_keys.erb"
      end

    end

  end

end