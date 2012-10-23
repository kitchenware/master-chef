
if node.timezone =~ /^([^\/]+)\/([^\/]+)$/

  zone, city = $1, $2

  target = "/usr/share/zoneinfo/#{zone}/#{city}"

  raise "No locatime file found for #{zone} : #{city}" unless File.exist? target

  link "/etc/localtime" do
    to target
  end

  file "/etc/timezone" do
    content node.timezone
    mode 0644
  end

else
  raise "Wrong timezone #{node.timezone}"
end

