
define :add_user_in_group, {
  :group => nil,
  } do

  add_user_in_group = params

  raise "Please specify group for add_user_in_group" unless add_user_in_group[:group]

  group add_user_in_group[:group] do
    action :manage
    members [add_user_in_group[:name]]
    append true
  end

end