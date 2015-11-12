
if File.exists?('/etc/init.d/logstash')

  service "logstash" do
    action [:disable, :stop]
  end

end

execute "purge old logstash install" do
  command "rm -rf /etc/init.d/logstash /etc/default/logstash /opt/logstash"
  only_if "[ -d /opt/logstash/shared ]"
end

execute "purge old logstash user" do
  command "userdel logstash && rm -rf /home/logstash"
  only_if "[ -d /home/logstash ]"
end
