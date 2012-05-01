
delayed_exec "Remove useless cron" do
  block do
    crons = find_resources_by_name_pattern(/^\/etc\/cron.d\/.*$/).map{|r| r.name}
    Dir["/etc/cron.d/*"].each do |n|
      Kernel.system "dpkg -S #{n} > /dev/null 2>&1"
      is_system_file = $?.exitstatus == 0
      unless is_system_file || crons.include?(n)
        Chef::Log.info "Removing cron #{n}"
        File.unlink n
        notifies :reload, resources(:service => "cron")
      end
    end
  end
end

cron_file "toto" do
  content "my_toto file"
end