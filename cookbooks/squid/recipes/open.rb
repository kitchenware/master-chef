
include_recipe "squid"

execute "configure squid for open access" do
  command "sed -ie 's/# INSERT YOUR OWN RULE.*$/acl my_net src 0.0.0.0\\/0\\nhttp_access allow my_net/' /etc/squid3/squid.conf"
  only_if "grep 'INSERT YOUR OWN RULE' /etc/squid3/squid.conf"
  notifies :restart, "service[squid3]"
end

execute "remove via on on squid config" do
  command "sed -ie 's/# via on/via off/' /etc/squid3/squid.conf"
  not_if "grep 'via off' /etc/squid3/squid.conf"
  notifies :restart, "service[squid3]"
end

execute "add ignore_expect_100 on on squid config" do
  command "sed -ie 's/# ignore_expect_100 off/ignore_expect_100 on/' /etc/squid3/squid.conf"
  not_if "grep 'ignore_expect_100 on' /etc/squid3/squid.conf"
  notifies :restart, "service[squid3]"
end
