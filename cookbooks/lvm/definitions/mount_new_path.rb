
define :mount_new_path, {
  :target => nil,
  :fstype => 'ext4',
  :format => true,
  :options => 'defaults',
  :owner => 'root',
  :group => 'root',
  :mode => '0700',
  :mkfs_options => ''
} do

  mount_new_path_params = params

  raise "Please specify target with mount_new_path" unless mount_new_path_params[:target]

  if mount_new_path_params[:format]
    format_fs mount_new_path_params[:name] do
      fstype mount_new_path_params[:fstype]
      mkfs_options mount_new_path_params[:mkfs_options]
    end
  end

  # not using directory resource to avoir conflicts
  execute "create fake folder to allow mount on #{mount_new_path_params[:target]}" do
    command "mkdir #{mount_new_path_params[:target]}"
    not_if "[ -d #{mount_new_path_params[:target]} ]"
  end

  mount mount_new_path_params[:target] do
    action [:mount, :enable]
    device mount_new_path_params[:name]
    fstype mount_new_path_params[:fstype]
    options mount_new_path_params[:options]
  end

  directory mount_new_path_params[:target] do
    owner mount_new_path_params[:owner]
    group mount_new_path_params[:group]
    mode mount_new_path_params[:mode]
  end

end
