
package "cron"

service "cron" do
  supports :status => true, :restart => true, :reload => true
  action node.cron.service_action
end

if node.cron.auto_purge

  include_recipe "cron::purge"

end
