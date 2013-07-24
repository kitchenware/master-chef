
if File.exists? "/opt/chef/bin/chef-solo"

  install_path = "/opt/master-chef"

  ["", "bin", "etc", "var", "var/git_repos"].each do |d|
    directory "#{install_path}/#{d}"
  end

  ["var/last", "tmp"].each do |d|
    directory "#{install_path}/#{d}" do
      owner node.master_chef.chef_solo_scripts.user
    end
  end

  template "#{install_path}/bin/master-chef.sh" do
    source "bootstrap.sh.erb"
    mode '0755'
  end

  template "#{install_path}/bin/update.impl.last.sh" do
    source "update_omnibus.sh.erb"
    mode '0755'
    variables({
      :user => node.master_chef.chef_solo_scripts.user,
      :use_formatter_logging => node.master_chef.chef_solo_scripts.use_formatter_logging,
    })
  end

  template "#{install_path}/bin/update.impl.sh" do
    source "update_omnibus.sh.erb"
    mode '0755'
    variables({
      :user => node.master_chef.chef_solo_scripts.user,
      :use_formatter_logging => node.master_chef.chef_solo_scripts.use_formatter_logging,
    })
    action :create_if_missing
  end

  template "#{install_path}/etc/solo.rb" do
    source "solo.rb.erb"
    mode '0644'
    variables :cache_directory => "#{install_path}/var", :var_chef => "/opt/chef/var"
  end

end

if File.exists? "/etc/chef"

  ["solo.rb", "rbenv_sudo_chef.sh", "update.sh"].each do |f|
    template "/etc/chef/#{f}" do
      mode (f =~ /\.sh$/ ? '0755' : '0644')
      source "#{f}.erb"
      variables({
        :user => node.master_chef.chef_solo_scripts.user,
        :user_home => get_home(node.master_chef.chef_solo_scripts.user),
        :log_prefix => "/tmp/last_chef",
        :config_file => "/etc/chef/local.json",
        :cache_directory => "/var/chef/cache",
        :var_chef => "/var/chef",
      })
    end
  end

end

package "unzip"
package "bzip2"
package "curl"
package "git-core"

Chef::Log.info "File for local storage : #{node.local_storage.file}"