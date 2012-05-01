
link "/etc/localtime" do
  to "/usr/share/zoneinfo/UTC"
end

template "/etc/timezone" do
  source "timezone.erb"
  mode 0644
  variables :timezone => node.timezone
end