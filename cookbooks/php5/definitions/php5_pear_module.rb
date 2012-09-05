
define :php5_pear_module, {
} do

  php5_pear_module_params = params

  bash "install pear module #{php5_pear_module_params[:name]}" do
    code "pear install #{php5_pear_module_params[:name]}"
    not_if "pear list | grep -i \"^#{php5_pear_module_params[:name]}\""
  end

end
