
define :base_user, {
  :home => nil
} do
  base_user_params = params

  user base_user_params[:name] do
    shell "/bin/bash"
    home base_user_params[:home] if base_user_params[:home]
  end

  if node[:bash_users]
    node.bash_users << base_user_params[:name]
  end

  user_home = base_user_params[:home] || get_home(base_user_params[:name])
  directory user_home do
    owner base_user_params[:name]
    mode 0755
  end

end
