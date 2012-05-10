

vmware_config_options = ""
vmware_config_options = "--clobber-kernel-modules=vmxnet3,pvscsi,vmmemctl" if %x{uname -r} =~ /^3.*$/

template "/etc/init.d/vmware-tools-update" do
  source "vmware-tools-update"
  variables :vmware_config_options => vmware_config_options
  mode 0755
end

link "/etc/rcS.d/S36vmware-tools-update" do
  to "/etc/init.d/vmware-tools-update"
end