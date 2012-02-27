

define :ruby_user, {
  :install_rbenv => false
} do

  ruby_user_params = params

  base_user ruby_user_params[:name]
  
  git "#{get_home ruby_user_params[:name]}/.warp" do
    user ruby_user_params[:name]
    repository "git://github.com/bpaquet/warp.git"
  end

  if ruby_user_params[:install_rbenv]
    bash "install rbenv" do
      user ruby_user_params[:name]
      code "export HOME=#{get_home ruby_user_params[:name]} && cd $HOME && .warp/common/ruby/setup_rbenv.sh"
      not_if "[ -d #{get_home ruby_user_params[:name]}/.rbenv ]"
    end
  end

  if node[:warp]

    template "#{get_home ruby_user_params[:name]}/.warp_src" do
      owner ruby_user_params[:name]
      source "warp_src.erb"
      cookbook "ruby"
      variables :warp_src => node.warp[:warp_src]
    end

  end

end
