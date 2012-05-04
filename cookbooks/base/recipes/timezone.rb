
if node.timezone =~ /^([^\/]+)\/([^\/]+)$/

  zone, city = $1, $2

  target = "/usr/share/zoneinfo/#{zone}/#{city}"

  raise "No locatime file found for #{node.timezone}" unless File.exist? target

  link "/etc/localtime" do
    to target
  end

  template "/etc/timezone" do
    source "timezone.erb"
    mode 0644
    variables :timezone => node.timezone
  end

else 
  raise "Wrong timezone #{node.timezone}"
end

