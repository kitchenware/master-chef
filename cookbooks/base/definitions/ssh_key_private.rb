
define :ssh_key_private, {
  :cookbook => nil,
  :base_name => nil,
} do
  ssh_key_private_params = params

  ssh_key_private_params[:base_name] = ssh_key_private_params[:name] unless ssh_key_private_params[:base_name]

  ssh_user_directory ssh_key_private_params[:base_name]

  template "#{get_home ssh_key_private_params[:name]}/.ssh/id_rsa" do
    cookbook ssh_key_private_params[:cookbook]
    source "#{ssh_key_private_params[:base_name]}_id_rsa"
    mode '0600'
    owner ssh_key_private_params[:name]
  end

  template "#{get_home ssh_key_private_params[:name]}/.ssh/id_rsa.pub" do
    cookbook ssh_key_private_params[:cookbook]
    source "#{ssh_key_private_params[:base_name]}_id_rsa.pub"
    mode '0600'
    owner ssh_key_private_params[:name]
  end

end