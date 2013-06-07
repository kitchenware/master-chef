
define :lvm_logical_volume, {
  :size => nil,
  :volume_group => nil,
} do

  lvm_logical_volume_params = params

  raise "Please specify size with lvm_logical_volume" unless lvm_logical_volume_params[:size]
  raise "Please specify volume_group with lvm_logical_volume" unless lvm_logical_volume_params[:volume_group]

  size = lvm_logical_volume_params[:size]
  size_option = (size =~ /^[+-]/ || size =~ /%/) ? "-l#{size}" : "-L#{size}"

  execute "create volume group #{lvm_logical_volume_params[:name]}" do
    command "lvcreate #{size_option} -n #{lvm_logical_volume_params[:name]} #{lvm_logical_volume_params[:volume_group]}"
    not_if "lvdisplay /dev/#{lvm_logical_volume_params[:volume_group]}/#{lvm_logical_volume_params[:name]}"
  end

end
