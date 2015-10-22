
define :lvm_cache, {
  :volume_group => nil,
  :lv_meta => nil,
  :lv_cache => nil,
  :fast_disk => nil,
  :slow_disk => nil,
  :cache_name => 'cache',
  :cache_size => '100%FREE',
  :metadata_name => 'metadata',
  :metadata_size => '16G',
  :size => nil,
} do

  include_recipe 'lvm::lvmcache'

  lvm_cache_params = params

  [:volume_group, :lv_meta, :lv_cache, :fast_disk, :slow_disk, :size].each do |x|
    raise "Please specify #{x} with lvm_cache" unless lvm_cache_params[x]
  end

  main_volume = "/dev/#{lvm_cache_params[:volume_group]}/#{lvm_cache_params[:name]}"
  cache_volume = "/dev/#{lvm_cache_params[:volume_group]}/#{lvm_cache_params[:cache_name]}"
  status = %x{lvs #{cache_volume} || true}.strip

  unless status.match(/#{lvm_cache_params[:volume_group]} Cwi/)
    lvm_logical_volume lvm_cache_params[:metadata_name] do
      volume_group lvm_cache_params[:volume_group]
      disk lvm_cache_params[:fast_disk]
      size lvm_cache_params[:metadata_size]
    end

    lvm_logical_volume lvm_cache_params[:cache_name] do
      volume_group lvm_cache_params[:volume_group]
      disk lvm_cache_params[:fast_disk]
      size lvm_cache_params[:cache_size]
    end

    lvm_logical_volume lvm_cache_params[:name] do
      volume_group lvm_cache_params[:volume_group]
      disk lvm_cache_params[:slow_disk]
      size lvm_cache_params[:size]
    end

    execute "link cache and metadata for #{lvm_cache_params[:name]}" do
      command "lvconvert -y --type cache-pool --cachemode writeback --chunksize 64k --poolmetadata #{lvm_cache_params[:volume_group]}/#{lvm_cache_params[:metadata_name]} #{lvm_cache_params[:volume_group]}/#{lvm_cache_params[:cache_name]}"
    end
  end

  execute "link cache to main volume for #{lvm_cache_params[:name]}" do
    command "lvconvert --type cache --cachepool #{lvm_cache_params[:volume_group]}/#{lvm_cache_params[:cache_name]} #{lvm_cache_params[:volume_group]}/#{lvm_cache_params[:name]}"
    not_if "lvs -o pool_lv #{main_volume} | grep #{lvm_cache_params[:cache_name]}"
  end

end
