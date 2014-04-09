
if node.purge_limits

  delayed_exec "Remove useless files in limits.d" do
    block do
      updated = false
      limits_files = find_resources_by_name_pattern(/^\/etc\/security\/limits\.d\/.*$/).map{|r| r.name}
      Dir["/etc/security/limits.d/*"].each do |n|
        Kernel.system "dpkg -S #{n} > /dev/null 2>&1"
        is_system_file = $?.exitstatus == 0
        unless is_system_file || limits_files.include?(n)
          Chef::Log.info "Removing limits #{n}"
          File.unlink n
          updated = true
        end
      end
      updated
    end
  end

end