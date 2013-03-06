
if node['platform'] == "ubuntu" || node['platform'] == "debian"

  ["http", "https"].each do |proto|
    if ENV['BACKUP_' + proto + '_proxy']

      execute "purge #{proto} proxy in apt.conf" do
        command "sed -ie '/Acquire::#{proto}::Proxy/d' /etc/apt/apt.conf"
        only_if "grep 'Acquire::#{proto}::Proxy' /etc/apt/apt.conf"
      end

      file "/etc/apt/apt.conf.d/00_#{proto}_proxy" do
        content <<-EOF
  Acquire::#{proto}::Proxy "#{ENV['BACKUP_' + proto + '_proxy']}";
  EOF
        mode 0644
      end

    end
  end

end