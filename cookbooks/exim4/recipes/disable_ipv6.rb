
execute "disable ipv6 on exim4" do
  command "sed -i 's|exim_path = /usr/sbin/exim4|exim_path = /usr/sbin/exim4\\ndisable_ipv6 = true|' /etc/exim4/exim4.conf.template"
  not_if "cat /etc/exim4/exim4.conf.template | grep disable_ipv6"
  notifies :restart, "service[exim4]"
end