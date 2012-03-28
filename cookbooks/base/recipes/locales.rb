
if node.locales.configure

  execute "locale-gen" do
    action :nothing
  end

  Dir["/var/lib/locales/supported.d"].each do |n|
    p n
    notifies :run, resources(:execute => "locale-gen"), :delayed
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