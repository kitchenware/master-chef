
if Ohai::VERSION =~ /^6/

  require_plugin "virtualization"

  if File.exist?("/proc/1/environ")
  proc_environ = File.read("/proc/1/environ")
    if proc_environ.match('lxc')
      virtualization[:system] = "linux-lxc"
      virtualization[:role] = "guest"
    end
  end

else

  Ohai.plugin(:Lxc) do
    depends "virtualization"

    collect_data(:default) do
      if File.exist?("/proc/1/environ")
        proc_environ = File.read("/proc/1/environ")
        if proc_environ.match('lxc')
          virtualization[:system] = "linux-lxc"
          virtualization[:role] = "guest"
        end
      end
    end
  end

end
