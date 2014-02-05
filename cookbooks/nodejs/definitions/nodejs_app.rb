
define :nodejs_app, {
  :user => nil,
  :script => nil,
  :directory => nil,
  :opts => nil,
  :file_check => [],
  :directory_check => [],
  :add_log_param => true,
  :node_env => "production",
  :check_start => nil,
  :logrotate_files => [],
  :no_capistrano_app => false,
} do

  nodejs_app_params = params

  raise "You have to specify user in nodejs_app" unless nodejs_app_params[:user]
  raise "You have to specify script in nodejs_app" unless nodejs_app_params[:script]

  include_recipe "capistrano"
  include_recipe "logrotate"

  directory = nodejs_app_params[:directory] || ::File.join(get_home(nodejs_app_params[:user]), nodejs_app_params[:name])

  current_path = ::File.join(directory, "current")
  extended_options = ""
  if nodejs_app_params[:add_log_param]
    extended_options += " --log_file #{directory}/shared/log/#{nodejs_app_params[:name]}.log"

    if node.logrotate[:auto_deploy]

      logrotate_file "nodejs_log_file_#{nodejs_app_params[:name]}" do
        files (["#{nodejs_app_params[:name]}.log"] + nodejs_app_params[:logrotate_files]).map{|x| "#{directory}/shared/log/#{x}"}
        variables :post_rotate => "kill -USR2 `cat #{directory}/shared/#{nodejs_app_params[:name]}.pid`", :user => nodejs_app_params[:user]
      end

    end

  end

  unless nodejs_app_params[:no_capistrano_app]
    capistrano_app directory do
      user nodejs_app_params[:user]
    end
  end

  template "#{directory}/shared/run_node_#{nodejs_app_params[:name]}.sh" do
    source "run_node.sh.erb"
    cookbook "nodejs"
    owner nodejs_app_params[:user]
    variables({
      :name => nodejs_app_params[:name],
      :extended_options => extended_options,
      :node_env => nodejs_app_params[:node_env],
      :stdout_log_file => "#{directory}/shared/log/#{nodejs_app_params[:name]}_stdout.log",
    })
    mode '0755'
  end

  if node.logrotate[:auto_deploy]

    logrotate_file "nodejs_stdout_#{nodejs_app_params[:name]}" do
      files ["#{directory}/shared/log/#{nodejs_app_params[:name]}_stdout.log"]
      user nodejs_app_params[:user]
      variables :copytruncate => true
    end

  end

  basic_init_d nodejs_app_params[:name] do
    daemon "#{directory}/shared/run_node_#{nodejs_app_params[:name]}.sh"
    file_check ["#{directory}/current/#{nodejs_app_params[:script]}"] + nodejs_app_params[:file_check]
    directory_check nodejs_app_params[:directory_check]
    options nodejs_app_params[:script]
    pid_directory "#{directory}/shared"
    user nodejs_app_params[:user]
    working_directory "#{directory}/current"
    vars_to_unset ["NVM_DIR"]
    code "export REDIRECT_OUTPUT=true"
    run_code "unset REDIRECT_OUTPUT"
    check_start nodejs_app_params[:check_start] if nodejs_app_params[:check_start]
  end

  file "/etc/default/#{nodejs_app_params[:name]}" do
    mode '0755'
    content "NODE_OPTS=\"#{nodejs_app_params[:opts]}\""
    notifies :restart, "service[#{nodejs_app_params[:name]}]"
  end

end
