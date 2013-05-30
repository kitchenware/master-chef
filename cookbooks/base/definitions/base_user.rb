
define :base_user, {
  :home => nil,
  :group => nil,
} do
  base_user_params = params

  if base_user_params[:group]

    group "create group for user #{base_user_params[:name]}" do
      group_name base_user_params[:group]
    end

  end

  user base_user_params[:name] do
    shell "/bin/bash"
    home base_user_params[:home] if base_user_params[:home]
    group base_user_params[:group] if base_user_params[:group]
  end

  if node[:bash_users]
    node.set[:bash_users] = node.bash_users + [base_user_params[:name]]
  end

  base_user_params[:home] ||= get_home(base_user_params[:name])

  directory base_user_params[:home] do
    recursive true
    owner base_user_params[:name]
    mode '0755'
  end

  file "#{base_user_params[:home]}/.bash_profile" do
    owner base_user_params[:name]
    mode '0700'
    action :create_if_missing
  end

end
