
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
