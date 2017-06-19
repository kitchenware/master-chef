
package "lvm2"
package "parted"

if node[:lvm][:fs_packages]
  node[:lvm][:fs_packages].each do |x|
    package x
  end
end

if node[:lvm][:partitions]
  node[:lvm][:partitions].each do |name, config|
    partition name do
      fs_type config[:fs_type]
    end
  end
end

if node[:lvm][:raid]

  package "mdadm"

  node[:lvm][:raid].each do |name, config|
    raid name do
      disks config[:disks]
      level config[:level]
    end
  end
end

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

if node[:lvm][:lvm_cache].is_a? Array
  node[:lvm][:lvm_cache].each do |name, lv|
    lvm_cache name do
      volume_group lv[:volume_group]
      lv_meta lv[:lv_meta]
      lv_cache lv[:lv_cache]
      fast_disk lv[:fast_disk]
      slow_disk lv[:slow_disk]
      size lv[:size]
    end
  end
end

node[:lvm][:mount_existing_path].each do |device, config|
  mount_existing_path device do
    target config[:target]
    fstype config[:fstype] if config[:fstype]
    format true if config[:format]
    impacted_services config[:impacted_services] if config[:impacted_services]
    options config[:options] if config[:options]
  end
end

node[:lvm][:mount_new_path].each do |device, config|
  mount_new_path device do
    target config[:target]
    fstype config[:fstype] if config[:fstype]
    format_fs true if config[:format_fs]
    options config[:options] if config[:options]
    mkfs_options config[:mkfs_options] if config[:mkfs_options]
    owner config[:owner] if config[:owner]
    mode config[:mode] if config[:mode]
  end
end
