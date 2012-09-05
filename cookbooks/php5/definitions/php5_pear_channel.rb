
define :php5_pear_channel, {
} do

  php5_pear_channel_params = params

  bash "install channel module #{php5_pear_channel_params[:name]}" do
    code "pear channel-discover #{php5_pear_channel_params[:name]}"
    not_if "pear channel-info #{php5_pear_channel_params[:name]}"
  end

end
