
define :warp_install, {
  :nvm => false,
  :rbenv => false,
} do

  warp_install_params = params

  git_clone "#{get_home warp_install_params[:name]}/.warp" do
    user warp_install_params[:name]
    reference node.warp[:reference]
    repository "git@github.com:bpaquet/warp.git"
  end
  
  if node[:warp_src]

    template "#{get_home warp_install_params[:name]}/.warp_src" do
      owner warp_install_params[:name]
      cookbook "warp"
      source "warp_src.erb"
      variables :warp_src => node[:warp_src]
    end

  end

  if warp_install_params[:nvm]

    execute "install nvm" do
      user warp_install_params[:name]
      environment "HOME" => get_home(warp_install_params[:name])
      command "#{get_home warp_install_params[:name]}/.warp/common/node/install_nvm.sh"
    end
  end

  if warp_install_params[:rbenv]

    execute "install rbenv" do
      user warp_install_params[:name]
      environment "HOME" => get_home(warp_install_params[:name])
      command "#{get_home warp_install_params[:name]}/.warp/common/ruby/install_rbenv.sh"
    end

  end

end
