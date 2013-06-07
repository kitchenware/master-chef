
define :lvm_physical_volume, {
} do

  lvm_physical_volume_params = params

  execute "create physical volume #{lvm_physical_volume_params[:name]}" do
    command "pvcreate #{lvm_physical_volume_params[:name]}"
    not_if "pvdisplay #{lvm_physical_volume_params[:name]}"
  end

end
