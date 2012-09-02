
["solo.rb", "rbenv_sudo_chef.sh", "update.sh"].each do |f|
  template "/etc/chef/#{f}" do
    mode (f =~ /\.sh$/ ? 0755 : 0644)
    source f
    variables({
      :user => node.master_chef.chef_solo_scripts.user,
      :user_home => get_home(node.master_chef.chef_solo_scripts.user),
      :log_prefix => node.master_chef.chef_solo_scripts.log_prefix,
      :config_file => node.master_chef.chef_solo_scripts.config_file,
    })
  end
end

package "unzip"
package "bzip2"
package "curl"
package "git-core"
