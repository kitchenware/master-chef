
require_plugin "virtualization"

if File.exist?("/proc/1/environ")
proc_environ = File.read("/proc/1/environ")
  if proc_environ.match('lxc-start')
    virtualization[:system] = "linux-lxc"
    virtualization[:role] = "guest"
  end
end
