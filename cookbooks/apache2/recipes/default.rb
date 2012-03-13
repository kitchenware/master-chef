
package "apache2-mpm-#{node.apache2.mpm}"


Chef::Config.exception_handlers << ServiceErrorHandler.new("apache2", ".*apache2.*")

service "apache2" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

template "/etc/apache2/apache2.conf" do
  variables :mpm => node.apache2.mpm_config
  source "apache2.conf.erb"
  notifies :reload, resources(:service => "apache2")
end

["/etc/apache2/sites-enabled/000-default", "/etc/apache2/sites-available/default", "/etc/apache2/sites-available/default-ssl"].each do |f|
  file f do
    action :delete
    notifies :reload, resources(:service => "apache2")
  end
end

delayed_exec "Remove useless apache2 vhost" do
  block do
    vhosts = find_resources_by_name_pattern(/^\/etc\/apache2\/sites-enabled\/.*\.conf$/).map{|r| r.name}
    Dir["/etc/apache2/sites-enabled/*.conf"].each do |n|
      unless vhosts.include? n
        Chef::Log.info "Removing vhost #{n}"
        File.unlink n
        notifies :reload, resources(:service => "apache2")
      end
    end
  end
end
