
if node.locales.configure

  available_locales = %x{cat /usr/share/i18n/SUPPORTED | grep -v ^#}.split("\n")

  node.locales.list.each do |l|
    raise "Locale not found on system #{l}" unless available_locales.include? l
  end

  execute "locale-gen" do
    action :nothing
  end

  if node.platform == "ubuntu"

    delayed_exec "Purge useless locales" do
      after_block_notifies :run, resources(:execute => "locale-gen")
      block do
        updated = false
        Dir["/var/lib/locales/supported.d/*"].each do |n|
          if n != "/var/lib/locales/supported.d/link"
            %x{rm -rf #{n}}
            updated = true
          end
        end
        updated
      end
    end

    link "/var/lib/locales/supported.d/link" do
      to "/etc/locale.gen"
    end

    node.locales.list.map{|x| x =~ /^(..)_/; $1}.uniq.each do |l|
      package "language-pack-#{l}"
    end

  end

  file "/etc/default/locale" do
    content "LANG=#{node.locales.default_locale}\nLC_ALL=#{node.locales.default_locale}\n"
    mode '0644'
  end

  file "/etc/locale.gen" do
    content node.locales.list.join("\n") + "\n"
    mode '0644'
    notifies :run, "execute[locale-gen]", :delayed
  end

end
