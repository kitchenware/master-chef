
directory "/etc/sudoers.d" do
  owner "root"
  mode '0755'
end

execute "add includedir /etc/sudoers.d in sudoers" do
  command "echo '#includedir /etc/sudoers.d' >> /etc/sudoers"
  not_if "cat /etc/sudoers | grep '#includedir /etc/sudoers.d'"
end

delayed_exec "Remove useless files in sudoers" do
  block do
    updated = false
    sudoers_files = find_resources_by_name_pattern(/^\/etc\/sudoers\.d\/.*$/).map{|r| r.name}
    Dir["/etc/sudoers.d/*"].each do |n|
      Kernel.system "dpkg -S #{n} > /dev/null 2>&1"
      is_system_file = $?.exitstatus == 0
      unless is_system_file || sudoers_files.include?(n)
        Chef::Log.info "Removing sudoers #{n}"
        File.unlink n
        updated = true
      end
    end
    updated
  end
end
