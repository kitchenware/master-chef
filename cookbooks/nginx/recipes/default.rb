if node.platform == "ubuntu" && node.apt.master_chef_add_apt_repo

  add_apt_repository "ppa_nginx" do
    url "http://ppa.launchpad.net/nginx/#{node.nginx.ubuntu_ppa_channel}/ubuntu"
    key "C300EE8C"
    key_server "keyserver.ubuntu.com"
  end

end

if node.lsb.codename == "squeeze"  && node.apt.master_chef_add_apt_repo

  add_apt_repository "nginx" do
    url "http://nginx.org/packages/debian/"
    components ["nginx"]
    key "7BD9BF62"
    key_server "keyserver.ubuntu.com"
  end

  directory "/etc/nginx/sites-enabled" do
    recursive true
  end

end

directory "/etc/nginx/modules.d"

if node.nginx[:nginx_version]

  package_fixed_version node.nginx.package_name do
    version node.nginx.nginx_version
  end

else

  package node.nginx.package_name do
    options node.nginx.nginx_package_options if node.nginx[:nginx_package_options]
  end

end

directory "etc/nginx/sites-enabled"

[
  "/etc/nginx/sites-enabled/default",
  "/etc/nginx/sites-available/default",
  ].each do |f|
  # file is not used, because file provider generates a warning in 11.6,
  # because some of this files can be symlink
  ruby_block "remove file deployed by nginx package #{f}" do
    block do
      File.unlink f if File.exists? f
    end
  end
end

Chef::Config.exception_handlers << ServiceErrorHandler.new("nginx", "nginx:.*")

service "nginx" do
  supports :status => true, :restart => true, :reload => true
  action auto_compute_action
  provider Chef::Provider::Service::Upstart if node.nginx[:use_upstart]
end

if node.nginx[:deploy_default_config]

  template "/etc/nginx/nginx.conf" do
    if node.nginx[:config][:worker_processes]
      nb_workers =  node.nginx[:config][:worker_processes]
    else
      nb_workers = node.cpu.total
    end
    variables :worker_processes => nb_workers, :worker_rlimit_nofile => node.nginx.config.worker_rlimit_nofile
    source "nginx.conf.erb"
    mode '0644'
    notifies :reload, "service[nginx]"
  end

  directory node.nginx.default_root do
    recursive true
    owner "www-data"
  end

  if node.nginx[:locations]

    node.nginx.locations.keys.sort.each do |k|
      directory node.nginx.locations[k]["path"] do
        owner node.nginx.locations[k]["owner"]
        recursive true
      end

      link "#{node.nginx.default_root}#{k}" do
        to node.nginx.locations[k]["path"]
      end
    end

  end

end

if node.nginx.default_vhost.enabled

  nginx_vhost "nginx:default_vhost" do
    cookbook "nginx"
    options :root => node.nginx.default_root
  end

end

if node.nginx[:proxy_locations]

  node.nginx.proxy_locations.each do |k, v|

    nginx_add_default_location k do
      upstream v[:upstram]
      content v[:content]
    end

  end

end

delayed_exec "Remove useless nginx vhost" do
  after_block_notifies :restart, resources(:service => "nginx")
  block do
    updated = false
    vhosts = find_resources_by_name_pattern(/^\/etc\/nginx\/sites-enabled\/.*\.conf$/).map{|r| r.name}
    Dir["/etc/nginx/sites-enabled/*.conf"].each do |n|
      unless vhosts.include? n
        Chef::Log.info "Removing vhost #{n}"
        File.unlink n
        updated = true
      end
    end
    updated
  end
end

delayed_exec "Remove useless nginx config" do
  after_block_notifies :restart, resources(:service => "nginx")
  block do
    updated = false
    configs = find_resources_by_name_pattern(/^\/etc\/nginx\/conf.d\/.*\.conf$/).map{|r| r.name}
    Dir["/etc/nginx/conf.d/*.conf"].each do |n|
      unless configs.include? n
        Chef::Log.info "Removing configs #{n}"
        File.unlink n
        updated = true
      end
    end
    updated
  end
end

delayed_exec "Remove useless nginx modules" do
  after_block_notifies :restart, resources(:service => "nginx")
  block do
    updated = false
    modules = find_resources_by_name_pattern(/^\/etc\/nginx\/modules.d\/.*\.conf$/).map{|r| r.name}
    Dir["/etc/nginx/modules.d/*.conf"].each do |n|
      unless modules.include? n
        Chef::Log.info "Removing modules #{n}"
        File.unlink n
        updated = true
      end
    end
    updated
  end
end