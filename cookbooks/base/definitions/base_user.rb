
define :base_user, {
  :home => nil,
  :group => nil,
} do
  base_user_params = params

  user base_user_params[:name] do
    shell "/bin/bash"
    home base_user_params[:home] if base_user_params[:home]
  end

  if base_user_params[:group]

    add_user_in_group base_user_params[:name] do
      group base_user_params[:group]
    end

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
