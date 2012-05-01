
service "cron" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

if node.cron.auto_purge

  include_recipe "cron::purge"
  
end
