
delayed_exec "Remove useless logrotate files" do
  block do
    files = find_resources_by_name_pattern(/^\/etc\/logrotate.d\/.*$/).map{|r| r.name}
    Dir["/etc/logrotate.d/*"].each do |n|
      unless files.include? n
        Kernel.system "dpkg -S #{n} > /dev/null 2>&1"
        if $?.exitstatus == 1
          Chef::Log.info "Removing logrotate file #{n}"
          File.unlink n
        end
      end
    end
  end
end

if node[:logrotate]
  node.logrotate.each do |k, v|
   logrotate_file k do
     files v
   end
 end
end

delayed_exec "Remove useless logrotate files" do
  block do
    files = find_resources_by_name_pattern(/^\/etc\/logrotate.d\/.*$/).map{|r| r.name}
  end
end