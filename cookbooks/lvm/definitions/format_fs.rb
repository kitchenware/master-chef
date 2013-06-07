define :format_fs, {
  :fstype => 'ext4',
  :mkfs_options => ''
} do

  format_fs_params = params

  execute "format #{format_fs_params[:name]} to #{format_fs_params[:fstype]}" do
    command "mkfs -t #{format_fs_params[:fstype]} #{format_fs_params[:mkfs_options]} #{format_fs_params[:name]}"
    not_if "blkid #{format_fs_params[:name]}"
  end

end
