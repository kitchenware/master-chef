
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
    :logging => node.master_chef.chef_solo_scripts.logging,
  })
end

template "#{install_path}/bin/update.impl.sh" do
  source "update_omnibus.sh.erb"
  mode '0755'
  variables({
    :user => node.master_chef.chef_solo_scripts.user,
    :logging => node.master_chef.chef_solo_scripts.logging,
  })
  action :create_if_missing
end

template "#{install_path}/etc/solo.rb" do
  source "solo.rb.erb"
  mode '0644'
  variables({
    :cache_directory => "#{install_path}/var",
    :var_chef => "/opt/chef/var",
    :logging => node.master_chef.chef_solo_scripts.logging,
  })
end

package "unzip"
package "bzip2"
package "curl"
package "git-core"

Chef::Log.info "File for local storage : #{node.local_storage.file}"