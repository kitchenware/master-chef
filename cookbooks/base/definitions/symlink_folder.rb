
define :symlink_folder, {
  :target => nil,
  :impacted_services => [],
} do
  symlink_folder_params = params

  raise "Please specify target for symlink_folder" unless symlink_folder_params[:target]

  stop_command =  "/bin/true" + symlink_folder_params[:impacted_services].reverse.map{|x| " && /etc/init.d/#{x} stop "}.join
  start_command = symlink_folder_params[:impacted_services].map{|x| "/etc/init.d/#{x} start && "}.join + "/bin/true"

  execute "symlink folder #{symlink_folder_params[:name]}" do
    command <<-EOF
    #{stop_command} &&
    mkdir -p #{symlink_folder_params[:target]} &&
    rsync -avh --delete #{symlink_folder_params[:name]}/ #{symlink_folder_params[:target]}/ &&
    rm -rf #{symlink_folder_params[:name]} &&
    ln -s #{symlink_folder_params[:target]} #{symlink_folder_params[:name]} &&
    #{start_command}
EOF
    action :nothing
  end

  delayed_exec "symlink folder #{symlink_folder_params[:target]}" do
    after_block_notifies :run, "execute[symlink folder #{symlink_folder_params[:name]}]"
    block do
      %x{ls -al #{symlink_folder_params[:name]} | grep #{symlink_folder_params[:target]}}
      $?.exitstatus != 0
    end
  end


end