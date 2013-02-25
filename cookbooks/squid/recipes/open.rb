
include_recipe "squid"

execute "configure squid for open access" do
  command "sed -ie 's/# INSERT YOUR OWN RULE.*$/acl my_net src 0.0.0.0\\/0\\nhttp_access allow my_net/' /etc/squid3/squid.conf"
  only_if "grep 'INSERT YOUR OWN RULE' /etc/squid3/squid.conf"
  notifies :restart, resources(:service => "squid3")
end