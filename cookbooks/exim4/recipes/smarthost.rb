
include_recipe "exim4::base"

template "/etc/exim4/update-exim4.conf.conf" do
  source "update-exim4.conf.erb"
  notifies :restart, resources(:service => "exim4")
end