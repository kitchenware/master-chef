
define :add_user_in_group, {
  :group => nil,
  } do

  add_user_in_group_params = params

  raise "Please specify group for add_user_in_group" unless add_user_in_group_params[:group]

  group add_user_in_group_params[:group] do
    action :manage
    members [add_user_in_group_params[:name]]
    append true
  end

end