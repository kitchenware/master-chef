
define :ruby_rbenv_command, {
  :user => nil,
  :directory => nil,
  :code => nil,
  :file_check => nil,
  :version => nil,
} do
  ruby_rbenv_command_params = params

  [:user, :code, :directory, :version].each do |s|
    raise "Please specify #{s} for ruby_rbenv_command" unless ruby_rbenv_command_params[s]
  end

  cmd = []
  cmd << "export HOME=#{get_home ruby_rbenv_command_params[:user]}"
  cmd << "export PATH=$HOME/.rbenv/bin:$PATH"
  cmd << "cd $HOME"
  cmd << "source .warp/common/ruby/include"
  cmd << "cd #{ruby_rbenv_command_params[:directory]}"
  cmd << "#{ruby_rbenv_command_params[:code]}"
  if ruby_rbenv_command_params[:file_check]
    not_if "[ -f #{ruby_rbenv_command_params[:file_check]} ]"
    cmd << "touch #{ruby_rbenv_command_params[:file_check]}"
  end

  execute_version "rbenv command : #{ruby_rbenv_command_params[:name]}" do
    user ruby_rbenv_command_params[:user]
    command cmd.join(" && ")
    file_storage "#{ruby_rbenv_command_params[:directory]}/.rbenv_#{ruby_rbenv_command_params[:name].gsub(/ /, '_')}"
  end

end
