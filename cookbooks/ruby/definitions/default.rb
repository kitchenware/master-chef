

define :ruby_user, {
} do

  ruby_user_params = params

  base_user ruby_user_params[:name]

  git "#{get_home ruby_user_params[:name]}" do
    user ruby_user_params[:name]
    repository "git://github.com/bpaquet/warp.git"
  end

  if node[:warp]

    template "#{get_home ruby_user_params[:name]}/.warp_src" do
      source "warp_src.erb"
      cookbook "ruby"
      variables :warp_src => node.warp[:warp_src]
    end

  end

end