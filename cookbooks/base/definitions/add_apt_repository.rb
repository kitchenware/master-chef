
define :add_apt_repository, {
  :url => nil,
  :distrib => nil,
  :components => [],
  :key => nil,
  :key_server => nil,
} do
  add_apt_repository_params = params

  raise "Please specify component (such as non-free) name of the deb repository" unless add_apt_repository_params[:components]

  execute "apt-get-update" do
    command "apt-get update"
    action :nothing
  end

  add_apt_repository_params[:distrib] = %x{lsb_release -cs}.strip unless add_apt_repository_params[:distrib]

  if add_apt_repository_params[:key] && add_apt_repository_params[:key_server]

    execute "add apt key for #{add_apt_repository_params[:name]}" do
      command "apt-key adv --keyserver #{add_apt_repository_params[:key_server]} --recv-keys #{add_apt_repository_params[:key]}"
      not_if "apt-key list | grep #{add_apt_repository_params[:key]}"
    end

  end

  file "/etc/apt/sources.list.d/#{add_apt_repository_params[:name]}.list" do
    content "deb #{add_apt_repository_params[:url]} #{add_apt_repository_params[:distrib]} #{add_apt_repository_params[:components].join(' ')}"
    mode '0644'
    notifies :run, "execute[apt-get-update]", :immediately
  end

end