
package "lvm2"

node[:lvm][:physical_volumes].each do |dev|
  lvm_physical_volume dev
end

node[:lvm][:volume_groups].each do |name, pvs|
  lvm_volume_group name do
    physical_volumes pvs
  end
end

node[:lvm][:logical_volumes].each do |name, lv|
  lvm_logical_volume name do
    volume_group lv[:volume_group]
    size lv[:size]
    fs_type lv[:fs_type] if lv[:fs_type]
  end
end

node[:lvm][:mount_existing_path].each do |device, config|
  mount_existing_path device do
    target config[:target]
    fstype config[:fstype] if config[:fstype]
    format config[:format] if config[:format]
    impacted_services config[:impacted_services] if config[:impacted_services]
    options config[:options] if config[:options]
  end
end

node[:lvm][:mount_new_path].each do |device, config|
  mount_new_path device do
    target config[:target]
    fstype config[:fstype] if config[:fstype]
    format config[:format] if config[:format]
    options config[:options] if config[:options]
    mkfs_options config[:mkfs_options] if config[:mkfs_options]
    owner config[:owner] if config[:owner]
    mode config[:mode] if config[:mode]
  end
end
