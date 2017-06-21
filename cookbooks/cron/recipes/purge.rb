
delayed_exec "Remove useless cron" do
  block do
    updated = false
    crons = find_resources_by_name_pattern(/^\/etc\/cron.d\/.*$/).map{|r| r.name}
    regex_filter = node.cron[:no_purge_matching_crons] || []
    Dir["/etc/cron.d/*"].each do |n|
      Kernel.system "dpkg -S #{n} > /dev/null 2>&1"
      is_system_file = $?.exitstatus == 0
      unless is_system_file || crons.include?(n) || regex_filter.inject(false) {|current, x| current || Regexp.new(x).match(File.basename(n))}
        Chef::Log.info "Removing cron #{n}"
        File.unlink n
        updated = true
      end
    end
    updated
  end
end
