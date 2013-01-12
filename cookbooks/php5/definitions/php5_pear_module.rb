
define :php5_pear_module, {
  :alldeps => true,
} do

  php5_pear_module_params = params

  opts = []
  opts << "--alldeps" if php5_pear_module_params[:alldeps]

  execute "install pear module #{php5_pear_module_params[:name]}" do
    command "pear install #{opts.join(' ')} #{php5_pear_module_params[:name]}"
    not_if "pear list-files #{php5_pear_module_params[:name]} > /dev/null"
  end

end
