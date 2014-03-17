
define :add_apt_key, {
  :key_server => nil,
  :key_url => nil,
} do
  add_apt_key_params = params

p add_apt_key_params
  raise "Please specify key_server or key_url with add_apt_key" unless add_apt_key_params[:key_server] || add_apt_key_params[:key_url]

  unless node.apt_keys.include? add_apt_key_params[:name]

    if add_apt_key_params[:key_server]
      params = ""
      params += "--keyserver-options http-proxy=#{ENV['BACKUP_http_proxy']}" if ENV['BACKUP_http_proxy']

      execute "add apt key #{add_apt_key_params[:name]}" do
        command "apt-key adv #{params} --keyserver #{add_apt_key_params[:key_server]} --recv-keys #{add_apt_key_params[:name]}"
        not_if "apt-key list | grep #{add_apt_key_params[:name]}"
      end
    end

    if add_apt_key_params[:key_url]
      execute "add apt key #{add_apt_key_params[:name]} from #{add_apt_key_params[:key_url]}" do
        command "curl #{add_apt_key_params[:key_url]} | apt-key add -"
        environment get_proxy_environment
        not_if "apt-key list | grep #{add_apt_key_params[:name]}"
      end
    end

    node.set[:apt_keys] = node.apt_keys + [add_apt_key_params[:name]]

  end

end


define :add_apt_repository, {
  :url => nil,
  :distrib => nil,
  :components => ["main"],
  :key => nil,
  :key_server => nil,
  :key_url => nil,
  :run_apt_get_update => true,
} do
  add_apt_repository_params = params

  raise "Please specify component (such as non-free) name of the deb repository" unless add_apt_repository_params[:components]

  add_apt_repository_params[:distrib] = %x{lsb_release -cs}.strip unless add_apt_repository_params[:distrib]

  if add_apt_repository_params[:key]

    add_apt_key add_apt_repository_params[:key] do
      key_server add_apt_repository_params[:key_server]
      key_url add_apt_repository_params[:key_url]
    end

  end

  file "/etc/apt/sources.list.d/#{add_apt_repository_params[:name]}.list" do
    content "deb #{add_apt_repository_params[:url]} #{add_apt_repository_params[:distrib]} #{add_apt_repository_params[:components].join(' ')}\n"
    mode '0644'
    notifies :run, "execute[run apt-get update]", :immediately if add_apt_repository_params[:run_apt_get_update]
  end

end
