
define :apache2_configuration_file, {
  :is_template => false,
  :content => '',
  :source => '',
  :variables => '',
  :mode => '644'
} do

  apache2_configuration_file_params = params

  unless apache2_configuration_file_params[:is_template]

    file "#{node.apache2.server_root}/conf.d/#{apache2_configuration_file_params[:name]}" do
      content apache2_configuration_file_params[:content]
      mode apache2_configuration_file_params[:mode]
      notifies :reload, "service[apache2]"
    end

  else

    template "#{node.apache2.server_root}/conf.d/#{apache2_configuration_file_params[:name]}" do
      source apache2_configuration_file_params[:source]
      variables apache2_configuration_file_params[:variables]
      mode apache2_configuration_file_params[:mode]
      notifies :reload, "service[apache2]"
    end

  end

end
