
include_recipe "exim4::base"

template "/etc/exim4/update-exim4.conf.conf" do
  source "smart_host.update-exim4.conf.erb"
  notifies :restart, resources(:service => "exim4")
end

if node.exim4.smarthost =~ /localhost/

  bash "add self = send to exim4.conf.template" do
    code "sed -i '/^smarthost/ a   self=send' /etc/exim4/exim4.conf.template "
    not_if "cat /etc/exim4/exim4.conf.template  | grep -A5 '^smarthost:' | grep self"
    notifies :restart, resources(:service => "exim4")
  end

else

  bash "remove self = send to exim4.conf.template" do
    code "sed -i '/^self/d' /etc/exim4/exim4.conf.template "
    only_if "cat /etc/exim4/exim4.conf.template  | grep -A5 '^smarthost:' | grep self"
    notifies :restart, resources(:service => "exim4")
  end

end