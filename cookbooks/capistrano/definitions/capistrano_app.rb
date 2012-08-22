define :capistrano_app, {
  :user => nil,
  :group => nil,
} do

  capistrano_app_params = params

  raise "Please specify user for capistrano_app" unless capistrano_app_params[:user]

  directories = []
  directories << capistrano_app_params[:name]
  directories << "#{capistrano_app_params[:name]}/shared"
  directories << "#{capistrano_app_params[:name]}/releases"
  directories << "#{capistrano_app_params[:name]}/shared/log"

  directories.each do |dir|
    directory dir do
      owner capistrano_app_params[:user]
      group capistrano_app_params[:group] if capistrano_app_params[:group]
      mode 0775
      recursive true
    end
  end

end