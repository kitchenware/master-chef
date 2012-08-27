
define :execute_version, {
  :command => nil,
  :user => "root",
  :version => "",
} do

  execute_install_params = params

  raise "Please specify command with execute_install" unless execute_install_params[:command]

  directory node.local_storage.version_storage

  installed_file = "#{node.local_storage.version_storage}/#{execute_install_params[:name].gsub(/ /, '_')}"

  execute "install #{execute_install_params[:name]}" do
    command "rm -f #{installed_file} && su #{execute_install_params[:user]} -c '#{execute_install_params[:command]}' && echo #{execute_install_params[:version]} > #{installed_file}"
    not_if "[ -f #{installed_file} ] && [ \"`cat #{installed_file}`\" = \"#{execute_install_params[:version]}\" ]"
  end

end