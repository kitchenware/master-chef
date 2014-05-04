
define :java_from_warp, {

} do

  version_name = params[:name]
  jdk = node.java.versions[version_name]

  warp_file = "#{jdk}_`arch`.warp"

  execute "install #{jdk}" do
    command "cd /tmp && curl --location #{node.warp.warp_src}/#{warp_file} -o #{warp_file} && sh #{warp_file} && rm #{warp_file}"
    environment get_proxy_environment
    not_if "[ -d /usr/lib/jvm/#{jdk} ]"
  end

  ["java", "javac", "jstat", "jps"].each do |x|

    execute "update alternative #{jdk} for #{x}" do
      command "update-alternatives --install /usr/bin/#{x} #{x} /usr/lib/jvm/#{jdk}/bin/#{x} 1"
      not_if "update-alternatives --list #{x} | grep #{jdk}"
    end

  end

end