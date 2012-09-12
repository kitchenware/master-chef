
include_recipe "cron"

package "munin"

execute "remove munin-cron" do
  command "sed -i -e '/munin-cron/d' /etc/cron.d/munin"
  only_if "grep munin-cron /etc/cron.d/munin"
end

template "/etc/munin/graph.sh" do
  source "graph.sh.erb"
  mode 0755
end

cron_file "munin-update" do
  content "*/5 * * * *     munin if [ -x /usr/share/munin/munin-update ]; then /usr/share/munin/munin-update; fi \n\n"
end
