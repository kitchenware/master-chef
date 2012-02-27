
define :base_user, {
  :home => nil,
  :group => nil,
} do
  base_user_params = params

  if base_user_params[:group]
    group base_user_params[:group]
  end

  user base_user_params[:name] do
    shell "/bin/bash"
    home base_user_params[:home] if base_user_params[:home]
    group base_user_params[:group] if base_user_params[:group]
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
