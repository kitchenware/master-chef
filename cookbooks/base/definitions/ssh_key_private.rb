
define :ssh_key_private, {
  :cookbook => nil,
} do
  ssh_key_private_params = params

  directory "#{get_home ssh_key_private_params[:name]}/.ssh" do
    mode 0700
  end

  template "#{get_home ssh_key_private_params[:name]}/.ssh/id_rsa" do
    cookbook ssh_key_private_params[:cookbook]
    source "#{ssh_key_private_params[:name]}_id_rsa"
    mode 0600
    owner ssh_key_private_params[:name]
  end

  template "#{get_home ssh_key_private_params[:name]}/.ssh/id_rsa.pub" do
    cookbook ssh_key_private_params[:cookbook]
    source "#{ssh_key_private_params[:name]}_id_rsa.pub"
    mode 0600
    owner ssh_key_private_params[:name]
  end

end