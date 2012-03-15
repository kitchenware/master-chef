
define :add_apt_repository, {
  :url => nil,
  :components => []
} do
  add_apt_repository_params = params

  raise "Please specify component (such as non-free) name of the deb repository" unless add_apt_repository_params[:components]

  bash "apt-get-update" do
    code "apt-get update"
    action :nothing
  end

  template "/etc/apt/sources.list.d/#{add_apt_repository_params[:name]}.list" do
    cookbook "base"
    variables :distrib => %x{lsb_release -cs}.strip, :components => add_apt_repository_params[:components], :url => add_apt_repository_params[:url]
    source "repository.erb" 
    mode 0644
    notifies :run, "bash[apt-get-update]", :immediately
  end

end