
if node.locales.configure

  execute "locale-gen" do
    action :nothing
  end

  template "/etc/locale.gen" do
    variables :locales => node.locales.list
    source "locale.gen.erb"
    mode 0644
    notifies :run, resources(:execute => "locale-gen"), :immediately
  end

  template "/etc/default/locale" do
    variables :locale => node.locales.default_locale
    source "locale.erb"
    mode 0644
  end

end