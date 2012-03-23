if node['platform'] == "ubuntu"
  base_ppa "nginx" do
     url "ppa:nginx/stable"
  end
end

if node['platform'] == "debian"

  authorize_unauthenticated_packages

  add_apt_repository "nginx" do
    url "http://nginx.org/packages/debian/"
    components ["nginx"]
  end

  directory "/etc/nginx/sites-enabled" do
    recursive true
  end
end

file "/etc/nginx/sites-enabled/default" do
  action :nothing
end

file "/etc/nginx/sites-available/default" do
  action :nothing
end

file "/etc/nginx/conf.d/default.conf" do
  action :nothing
end

package "nginx" do
  version node.nginx[:nginx_version] if node.nginx[:nginx_version]
  notifies :delete, resources(:file => "/etc/nginx/sites-enabled/default")
  notifies :delete, resources(:file => "/etc/nginx/sites-available/default")
  notifies :delete, resources(:file => "/etc/nginx/conf.d/default.conf")
end

Chef::Config.exception_handlers << ServiceErrorHandler.new("nginx", "nginx:.*")

service "nginx" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

if node.nginx[:deploy_default_config]

  template "/etc/nginx/nginx.conf" do
    source "nginx.conf.erb"
    mode 0644
    notifies :reload, resources(:service => "nginx")
  end

  directory node.nginx.default_root do
    recursive true
    owner "nginx"
  end

  if node.nginx[:locations] 
    node.nginx.locations.keys.sort.each do |k|
      directory "#{node.nginx.locations[k]["path"]}" do
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

delayed_exec "Remove useless nginx vhost" do
  block do
    vhosts = find_resources_by_name_pattern(/^\/etc\/nginx\/sites-enabled\/.*\.conf$/).map{|r| r.name}
    Dir["/etc/nginx/sites-enabled/*.conf"].each do |n|
      unless vhosts.include? n
        Chef::Log.info "Removing vhost #{n}"
        File.unlink n
        notifies :reload, resources(:service => "nginx")
      end
    end
  end

end
