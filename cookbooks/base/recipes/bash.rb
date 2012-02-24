
unless node[:no_bash_config]
  
  template "/etc/bash.bashrc" do
    source "bashrc.erb"
    owner "root"
    group "root"
    mode 0644
  end

  if node[:bash_users]

    node.bash_users.each do |user|
      file "#{get_home user}/.bashrc" do
        action :delete
      end
    end

  end

end