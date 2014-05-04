
define :collectd_exec_plugin, {
  :user => nil,
  :group => nil,
  :command => nil,
} do

  collectd_exec_plugin_params = params

  raise "Please specify user with collectd_exec_plugin" unless collectd_exec_plugin_params[:user]
  raise "Please specify command with collectd_exec_plugin" unless collectd_exec_plugin_params[:command]

  collectd_exec_plugin_params[:conf_file_name] ||= "#{collectd_exec_plugin_params[:name]}.conf.erb"
  collectd_exec_plugin_params[:python_file_name] ||= "#{collectd_exec_plugin_params[:name]}.py.erb"

  incremental_template_content collectd_exec_plugin_params[:name] do
    target node.collectd.exec_plugin.file
    content "Exec \"#{collectd_exec_plugin_params[:user]}:#{collectd_exec_plugin_params[:group] || ''}\" #{collectd_exec_plugin_params[:command]}"
  end

end