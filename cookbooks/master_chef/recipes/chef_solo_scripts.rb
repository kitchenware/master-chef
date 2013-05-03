
if File.exists? "/opt/chef/bin/chef-solo"

  directory "/opt/chef/etc"
  directory "/opt/chef/var"
  directory "/opt/chef/var/git_repos"

  directory "/opt/chef/var/last" do
    owner node.master_chef.chef_solo_scripts.user
  end

  template "/opt/chef/bin/master-chef.sh" do
    source "bootstrap.sh"
    mode '0755'
  end

  template "/opt/chef/bin/master-chef.impl.last.sh" do
    source "master-chef.sh"
    mode '0755'
    variables({
      :user => node.master_chef.chef_solo_scripts.user,
    })
  end

  template "/opt/chef/bin/master-chef.impl.sh" do
    source "master-chef.sh"
    mode '0755'
    variables({
      :user => node.master_chef.chef_solo_scripts.user,
    })
    action :create_if_missing
  end

  template "/opt/chef/etc/solo.rb" do
    source "solo.rb"
    mode '0644'
    variables :cache_directory => "/opt/chef/var"
  end

end

if File.exists? "/etc/chef"

  ["solo.rb", "rbenv_sudo_chef.sh", "update.sh"].each do |f|
    template "/etc/chef/#{f}" do
      mode (f =~ /\.sh$/ ? '0755' : '0644')
      source f
      variables({
        :user => node.master_chef.chef_solo_scripts.user,
        :user_home => get_home(node.master_chef.chef_solo_scripts.user),
        :log_prefix => "/tmp/last_chef",
        :config_file => "/etc/chef/local.json",
        :cache_directory => "/var/chef/cache",
      })
    end
  end

end

package "unzip"
package "bzip2"
package "curl"
package "git-core"
