
define :ssh_user_directory, {
  :action => :create
} do

  ssh_user_directory_params = params

  dir = "#{get_home ssh_user_directory_params[:name]}/.ssh"

  r = find_resources_by_name(dir)

  if r.empty?

    directory dir do
      mode '0700'
      owner ssh_user_directory_params[:name]
      action ssh_user_directory_params[:action]
    end

  else

    if ssh_user_directory_params[:action] == :create && r.length == 1 && r.first.action.length > 0 && r.first.action.first == :nothing
      ruby_block "launch home directory creation for user #{ssh_user_directory_params[:name]}" do
        block do
          r.first.run_action :create
        end
      end
    end

  end

  dir

end