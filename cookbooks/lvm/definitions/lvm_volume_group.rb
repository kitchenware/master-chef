
define :lvm_volume_group, {
  :physical_volumes => []
} do

  lvm_volume_group_params = params

  raise "Please specify at least one volume in physical_volumes for lvm_volume_group" if lvm_volume_group_params[:physical_volumes].length == 0

  execute "initialize volume group #{lvm_volume_group_params[:name]}" do
    command "vgcreate #{lvm_volume_group_params[:name]} #{lvm_volume_group_params[:physical_volumes].join(' ')}"
    not_if "vgdisplay #{lvm_volume_group_params[:name]}"
  end

end
