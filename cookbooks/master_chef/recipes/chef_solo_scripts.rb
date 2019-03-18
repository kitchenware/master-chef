
install_path = "/opt/master-chef"

["", "bin", "etc", "var"].each do |d|
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

no_git_dir = "/tmp/master_chef_repos"
template "#{install_path}/etc/solo.rb" do
  source "solo.rb.erb"
  mode '0644'
  variables({
    :cache_directory => "#{install_path}/var",
    :var_chef => "/opt/chef/var",
    :logging => node.master_chef.chef_solo_scripts.logging,
    :http_proxy => "\"http://#{node.proxyweb.host}\"",
    :https_proxy => "\"http://#{node.proxyweb.host}\"",
    :no_git_cache => node.master_chef.chef_solo_scripts.no_git_cache,
    :no_git_dir => no_git_dir
  })
end

unless node.proxyweb.host.empty?
  Chef::Log.info "HTTP(s) proxy used for external connections: #{node.proxyweb.host}"

  file '/opt/master-chef/etc/http_proxy' do
    owner 'root'
    group 'root'
    mode '0644'
    content "http://#{node.proxyweb.host}"
  end
end

if node.master_chef.chef_solo_scripts.no_git_cache
  MasterChefHooks.add_all "remove_git_cache", <<-EOF
#!/bin/bash

rm -rf #{no_git_dir}
EOF
end

Chef::Log.info "File for local storage : #{node.local_storage.file}"
