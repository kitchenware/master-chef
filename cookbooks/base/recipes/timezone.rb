
if node.timezone =~ /^([^\/]+)\/([^\/]+)$/

  zone, city = $1, $2

  target = "/usr/share/zoneinfo/#{zone}/#{city}"

  raise "No locatime file found for #{zone} : #{city}" unless File.exist? target

  link "/etc/localtime" do
    to target
  end

  execute "restart rsyslog after timezone change" do
    command "if [ -x /etc/init.d/rsyslog ]; then /etc/init.d/rsyslog restart; fi"
    action :nothing
  end

  file "/etc/timezone" do
    content node.timezone
    mode '0644'
    notifies :run, "execute[restart rsyslog after timezone change]"
  end

else
  raise "Wrong timezone #{node.timezone}"
end

