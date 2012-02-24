
define :base_user, {
} do
  base_user_params = params

  user base_user_params[:name] do
    shell "/bin/bash"
  end

  if node[:bash_users]
    node << base_user_params[:name]
  end

  directory get_home(base_user_params[:name]) do
    owner base_user_params[:name]
    mode 0700
  end

end
