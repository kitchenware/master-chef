
include_recipe "exim4::base"

template "/etc/exim4/update-exim4.conf.conf" do
  source "relay.update-exim4.conf.erb"
  notifies :restart, "service[exim4]"
end
