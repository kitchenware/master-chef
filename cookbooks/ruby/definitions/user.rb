
define :ruby_user, {
  :install_rbenv => false
} do

  ruby_user_params = params

  base_user ruby_user_params[:name]
  
  warp_install ruby_user_params[:name] do
    rbenv ruby_user_params[:install_rbenv]
  end
  
  file "#{get_home ruby_user_params[:name]}/.bash_profile" do
    owner ruby_user_params[:name]
    action :create_if_missing
  end

  template "#{get_home ruby_user_params[:name]}/.gemrc" do
    owner ruby_user_params[:name]
    source "gemrc.erb"
    cookbook "ruby"
  end

end
