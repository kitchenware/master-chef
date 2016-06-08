
define :collectd_tail_plugin, {
  :file => nil,
  :instance => nil,
  :match => nil,
} do

  collectd_tail_plugin_params = params

  raise "Please specify file with collectd_tail_plugin" unless collectd_tail_plugin_params[:file]
  raise "Please specify instance with collectd_tail_plugin" unless collectd_tail_plugin_params[:instance]
  raise "Please specify match with collectd_tail_plugin" unless collectd_tail_plugin_params[:match]

  incremental_template_content collectd_tail_plugin_params[:name] do
    target "#{node.collectd.config_directory}/tail.conf"
    content <<-EOF
<File "#{collectd_tail_plugin_params[:file]}">
  Instance "#{collectd_tail_plugin_params[:instance]}"
  #{collectd_tail_plugin_params[:match]}
</File>
EOF
  end

end