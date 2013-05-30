
define :collectd_python_plugin, {
  :config => nil,
  :template_cookbook => nil,
  :conf_file_name => nil,
  :python_file_name => nil,
} do

  collectd_python_plugin_params = params

  collectd_python_plugin_params[:conf_file_name] ||= "#{collectd_python_plugin_params[:name]}.conf.erb"
  collectd_python_plugin_params[:python_file_name] ||= "#{collectd_python_plugin_params[:name]}.py.erb"

  template "#{node.collectd.python_plugin.directory}/#{collectd_python_plugin_params[:name]}.py" do
    variables collectd_python_plugin_params[:config]
    cookbook collectd_python_plugin_params[:template_cookbook] if collectd_python_plugin_params[:template_cookbook]
    source collectd_python_plugin_params[:python_file_name]
    mode '0644'
    owner 'root'
    group 'root'
    notifies :restart, "service[collectd]"
  end

  incremental_template_part collectd_python_plugin_params[:name] do
    cookbook collectd_python_plugin_params[:template_cookbook] if collectd_python_plugin_params[:template_cookbook]
    target node.collectd.python_plugin.file
    source collectd_python_plugin_params[:conf_file_name]
  end

end