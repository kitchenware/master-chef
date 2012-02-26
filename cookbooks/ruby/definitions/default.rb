

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

define :ruby_rbenv_command, {
  :user => nil,
  :directory => nil,
  :code => nil,
  :file_check => nil,
} do
  ruby_rbenv_command_params = params

  raise "Please specify user for ruby_rbenv_command" unless ruby_rbenv_command_params[:user]
  raise "Please specify code for ruby_rbenv_command" unless ruby_rbenv_command_params[:code]
  raise "Please specify directory for ruby_rbenv_command" unless ruby_rbenv_command_params[:directory]

  bash "rbenv command : #{ruby_rbenv_command_params[:name]}" do
    user ruby_rbenv_command_params[:user]
    cmd = []
    cmd << "unset RBENV_DIR"
    cmd << "unset RBENV_HOOK_PATH"
    cmd << "unset RBENV_ROOT"
    cmd << "export HOME=#{get_home ruby_rbenv_command_params[:user]}"
    cmd << "export PATH=$HOME/.rbenv/bin:$PATH"
    cmd << "eval \"$(rbenv init -)\""
    cmd << "cd #{ruby_rbenv_command_params[:directory]}"
    cmd << "#{ruby_rbenv_command_params[:code]}"
    if ruby_rbenv_command_params[:file_check]
      not_if "[ -f #{ruby_rbenv_command_params[:file_check]} ]"
      cmd << "touch #{ruby_rbenv_command_params[:file_check]}"
    end
    code cmd.join(" && ")
    
  end

end
