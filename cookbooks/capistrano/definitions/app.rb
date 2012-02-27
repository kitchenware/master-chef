define :capistrano_app, {
  :user => nil,
  :without_cap => false,
} do

  capistrano_app_params = params
  
  raise "Please specify user for capsitrano_app" unless capistrano_app_params[:user]
  
  directories = []
  directories << capistrano_app_params[:name]
  directories << "#{capistrano_app_params[:name]}/shared"
  directories << "#{capistrano_app_params[:name]}/releases"
  if capistrano_app_params[:without_cap]
    directories << "#{capistrano_app_params[:name]}/shared/log" 
    directories << "#{capistrano_app_params[:name]}/shared/pids" 
    directories << "#{capistrano_app_params[:name]}/current" 
  end

  directories.each do |dir|
    directory dir do
      owner capistrano_app_params[:user]
    end
  end

end 