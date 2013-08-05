define :mount_existing_path, {
  :target => nil,
  :fstype => 'ext4',
  :format => true,
  :impacted_services => [],
  :options => 'defaults',
  :mkfs_options => '',
} do

  mount_existing_path_params = params

  raise "Please specify target with mount_existing_path" unless mount_existing_path_params[:target]

  if mount_existing_path_params[:format]

    format_fs mount_existing_path_params[:name] do
      fstype mount_existing_path_params[:fstype]
      mkfs_options mount_existing_path_params[:mkfs_options]
    end

  end

  mount mount_existing_path_params[:target] do
    action :enable
    device mount_existing_path_params[:name]
    fstype mount_existing_path_params[:fstype]
    options mount_existing_path_params[:options]
  end

  stop_command =  "/bin/true " + mount_existing_path_params[:impacted_services].reverse.map{|x| " && /etc/init.d/#{x} stop "}.join
  start_command = mount_existing_path_params[:impacted_services].map{|x| "/etc/init.d/#{x} start && "}.join + "/bin/true"

  execute "mount #{mount_existing_path_params[:target]}" do
    command <<-EOF
    #{stop_command} &&
    export tmp_mount=`mktemp` &&
    rm -rf $tmp_mount &&
    mkdir -p $tmp_mount &&
    mount -t #{mount_existing_path_params[:fstype]} #{mount_existing_path_params[:name]} $tmp_mount &&
    rsync -avh --delete #{mount_existing_path_params[:target]}/ $tmp_mount/ &&
    rm -rf #{mount_existing_path_params[:target]} &&
    mkdir #{mount_existing_path_params[:target]} &&
    umount $tmp_mount &&
    mount #{mount_existing_path_params[:target]} &&
    mkdir -p #{mount_existing_path_params[:target]}/lost+found &&
    rm -rf $tmp_mount &&
    #{start_command}
EOF
    action :nothing
  end

  delayed_exec "queue mount #{mount_existing_path_params[:target]}" do
    after_block_notifies :run, "execute[mount #{mount_existing_path_params[:target]}]"
    block do
      %x{mount | grep #{mount_existing_path_params[:target]}}
      $?.exitstatus != 0
    end
  end

end
