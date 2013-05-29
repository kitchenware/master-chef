
define :ssh_user_directory, {
  :action => :create
} do

  ssh_user_directory_params = params

  dir = "#{get_home ssh_user_directory_params[:name]}/.ssh"

  r = find_resources_by_name(dir)
  r.first.run_action :create if ssh_user_directory_params[:action] == :create && r.length == 1 && r.first.action.length > 0 && r.first.action.first == :nothing

  if r.empty?

    directory dir do
      mode '0700'
      owner ssh_user_directory_params[:name]
      action ssh_user_directory_params[:action]
    end

    dir

  else

    nil

  end

end