
unless node[:no_bash_config]
  
  template "/etc/bash.bashrc" do
    source "bashrc.erb"
    owner "root"
    group "root"
    mode 0644
  end

end