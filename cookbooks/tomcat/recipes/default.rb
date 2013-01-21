include_recipe "java"

package "libapr1"

base_user node.tomcat.user do
  home node.tomcat.home
end

execute "install tomcat via warp" do
  user node.tomcat.user
  command "cd #{node.tomcat.home} && curl --location #{node.warp.warp_src}/#{node.tomcat.warp_file} -o #{node.tomcat.warp_file} && sh #{node.tomcat.warp_file} && rm #{node.tomcat.warp_file}"
  not_if "[ -d #{node.tomcat.catalina_home} ]"
end

execute "change owner for security" do
  command "sudo chown -R root:root #{node.tomcat.catalina_home} && find #{node.tomcat.catalina_home}/ -type f -exec chmod a+r {} \\; "
end

directory "#{node.tomcat.instances_base}" do
  owner node.tomcat.user
end

["manager.xml", "host-manager.xml"].each do |f|
  file "#{node.tomcat.catalina_home}/conf/Catalina/localhost/#{f}" do
    action :delete
  end
end

directory node.tomcat.log_dir do
  owner node.tomcat.user
end

if node.tomcat[:instances]

  node.tomcat.instances.keys.each do |k|
    node.set[:tomcat][:instances][k][:name] = k
    tomcat_instance "tomcat:instances:#{k}" do
      instance_name k
    end
  end

end