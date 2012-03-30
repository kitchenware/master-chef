
template "/etc/init.d/vmware-tools-update" do
  source "vmware-tools-update"
  mode 0755
end

link "/etc/rcS.d/S36vmware-tools-update" do
  to "/etc/init.d/vmware-tools-update"
end