

define :add_yum_repository, {
} do
  add_yum_repository_params = params

  filename = File.basename(add_yum_repository_params[:name])

  execute "add yum repo #{filename}" do
    command "curl #{add_yum_repository_params[:name]} > /etc/yum.repos.d/#{filename}"
    environment get_proxy_environment
    not_if "[ -f /etc/yum.repos.d/#{filename} ]"
  end

end