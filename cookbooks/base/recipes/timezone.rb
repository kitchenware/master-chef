
if node.timezone =~ /^([^\/]+)\/([^\/]+)$/

  zone, city = $1, $2

  target = "/usr/share/zoneinfo/#{zone}/#{city}"

  raise "No locatime file found for #{zone} : #{city}" unless File.exist? target

  link "/etc/localtime" do
    to target
  end

  rsyslog_present = File.exists? "/etc/init.d/rsyslog"

  if rsyslog_present
    service "rsyslog" do
      supports :restart => true
      action :nothing
    end
  end

  file "/etc/timezone" do
    content node.timezone
    mode '0644'
    notifies :restart, "service[rsyslog]" if rsyslog_present
  end

else
  raise "Wrong timezone #{node.timezone}"
end

