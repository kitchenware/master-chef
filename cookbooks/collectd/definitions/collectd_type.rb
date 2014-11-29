
define :collectd_type, {
  :definition => nil,
} do

  collectd_type_params = params

  execute "add collectd type #{collectd_type_params[:name]}" do
  	command "echo #{collectd_type_params[:name]} #{collectd_type_params[:definition]} >> /usr/share/collectd/types.db"
  	not_if "cat /usr/share/collectd/types.db | grep '^#{collectd_type_params[:name]}'"
  	notifies :restart, "service[collectd]"
  end

end