
define :execute_version, {
  :command => nil,
  :user => "root",
  :version => "",
  :notifies => nil,
} do

  execute_version_params = params

  raise "Please specify command with execute_version" unless execute_version_params[:command]

  directory node.local_storage.version_storage

  installed_file = "#{node.local_storage.version_storage}/#{execute_version_params[:name].gsub(/ /, '_')}"

  execute "install #{execute_version_params[:name]}" do
    command "rm -f #{installed_file} && su #{execute_version_params[:user]} -c '#{execute_version_params[:command]}' && echo #{execute_version_params[:version]} > #{installed_file}"
    not_if "[ -f #{installed_file} ] && [ \"`cat #{installed_file}`\" = \"#{execute_version_params[:version]}\" ]"
    notifies execute_version_params[:notifies][0], execute_version_params[:notifies][1] if execute_version_params[:notifies]
  end

end