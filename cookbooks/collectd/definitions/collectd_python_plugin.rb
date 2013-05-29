
define :collectd_python_plugin, {
  :config => nil,
  :template_cookbook => nil,
  :conf_file_name => nil,
  :python_file_name => nil
} do

collectd_plugin_params = params

python_file = collectd_plugin_params[:python_file_name] || "#{collectd_plugin_params[:name]}.py.erb"

template "/opt/collectd/lib/collectd/plugins/python/#{collectd_plugin_params[:name]}.py" do
  variables collectd_plugin_params[:config]
  cookbook collectd_plugin_params[:template_cookbook]
  source python_file
  mode '0644'
  owner 'root'
  group 'root'
  notifies :restart, "service[collectd]"
end

conf_file = collectd_plugin_params[:conf_file_name] || "#{collectd_plugin_params[:name]}.conf.erb"

incremental_template_part '#{collectd_plugin_params[:name]}' do
  cookbook "#{collectd_plugin_params[:template_cookbook]}"
  target node.collectd.python_plugin.file
  source conf_file
end


end