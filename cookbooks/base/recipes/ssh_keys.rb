
if node[:ssh_keys]

  node[:resolved_ssh_keys] = {}

  node.ssh_keys.each do |name, config|

    if config["users"]
      config["users"].each do |user|
        node.resolved_ssh_keys[user] = [] unless node.resolved_ssh_keys[user]
        node.resolved_ssh_keys[user] += config["keys"] if config["keys"]
        if config["ref"]
          config["ref"].each do |k|
            node.resolved_ssh_keys[user] += node.ssh_keys[k]["keys"]
          end
        end
      end
    end

  end

  node.resolved_ssh_keys.each do |user, keys|
    home = get_home user

    directory "#{home}/.ssh" do
      owner user
      mode 0700
      action :nothing
    end

    execute "config ssh for #{user}" do
      command "echo #{user}"
      notifies :create, "directory[#{home}/.ssh]", :delayed
      notifies :create, "file[#{home}/.ssh/authorized_keys]", :delayed
    end

    file "#{home}/.ssh/authorized_keys" do
      owner user
      mode 0700
      content keys.uniq.sort.join("\n")
      action :nothing
    end

  end

end
