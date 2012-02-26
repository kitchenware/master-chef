
bash "add ppa nginx" do
  code "add-apt-repository ppa:nginx/stable && apt-get update"
  not_if "ls /etc/apt/sources.list.d | grep nginx"
end

package "nginx" do
  version node.nginx[:nginx_version] if node.nginx[:nginx_version]
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

  file "/etc/nginx/sites-enabled/default" do
    action :delete
  end

  file "/etc/nginx/sites-available/default" do
    action :delete
  end

end

nginx_vhost "nginx:default_vhost" do
  cookbook "nginx"
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
