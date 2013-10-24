
if node.platform == "ubuntu" || node.platform == "debian"

  ["http", "https"].each do |proto|
    execute "purge #{proto} proxy in apt.conf" do
      command "sed -i '/Acquire::#{proto}::Proxy/d' /etc/apt/apt.conf"
      only_if "grep 'Acquire::#{proto}::Proxy' /etc/apt/apt.conf"
    end

    if node.apt.configure_proxy_from_env && ENV['BACKUP_' + proto + '_proxy']

      file "/etc/apt/apt.conf.d/00_#{proto}_proxy" do
        content <<-EOF
  Acquire::#{proto}::Proxy "#{ENV['BACKUP_' + proto + '_proxy']}";
  EOF
        mode 0644
      end

    else

      file "/etc/apt/apt.conf.d/00_#{proto}_proxy" do
        action :delete
      end

    end

  end

end