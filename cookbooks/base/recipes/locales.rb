
if node.locales.configure

  execute "locale-gen" do
    action :nothing
  end

  if node['platform'] == "ubuntu"

    delayed_exec "Purge useless locales" do
      block do
        Dir["/var/lib/locales/supported.d/*"].each do |n|
          if n != "/var/lib/locales/supported.d/link"
            %x{rm -rf #{n}}
            notifies :run, resources(:execute => "locale-gen"), :delayed
          end
        end
      end
    end

    link "/var/lib/locales/supported.d/link" do
      to "/etc/locale.gen"
    end

  end

  template "/etc/locale.gen" do
    variables :locales => node.locales.list
    source "locale.gen.erb"
    mode 0644
    notifies :run, resources(:execute => "locale-gen"), :delayed
  end

  template "/etc/default/locale" do
    variables :locale => node.locales.default_locale
    source "locale.erb"
    mode 0644
  end

end
