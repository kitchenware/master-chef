
define :php5_pear_module, {
} do

  php5_pear_module_params = params

  execute "install pear module #{php5_pear_module_params[:name]}" do
    command "pear install #{php5_pear_module_params[:name]}"
    not_if "pear list-files #{php5_pear_module_params[:name]} > /dev/null"
  end

end
