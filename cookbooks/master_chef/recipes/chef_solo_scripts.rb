
["solo.rb", "rbenv_sudo_chef.sh", "update.sh"].each do |f|
  template "/etc/chef/#{f}" do
    mode (f =~ /\.sh$/ ? 0755 : 0644)
    source f
    variables({
      :user => node.master_chef.chef_solo_scripts.user,
      :user_home => get_home(node.master_chef.chef_solo_scripts.user),
      :status_file => node.master_chef.chef_solo_scripts.status_file,
      :log_file => node.master_chef.chef_solo_scripts.log_file,
      :config_file => node.master_chef.chef_solo_scripts.config_file,
    })
  end
end
