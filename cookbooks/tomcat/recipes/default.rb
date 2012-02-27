include_recipe "java"

package "libapr1"

base_user node.tomcat.user do
  home node.tomcat.home
  group node.tomcat.group
end

bash "install tomcat via warp" do
  user node.tomcat.user
  code "cd #{node.tomcat.home} && wget #{node.warp.warp_src}/#{node.tomcat.warp_file} && sh #{node.tomcat.warp_file} && rm #{node.tomcat.warp_file}"
  not_if "[ -d #{node.tomcat.catalina_home} ]"
end

directory "#{node.tomcat.instances_base}" do
  owner node.tomcat.user
end

directory node.tomcat.log_dir do
  owner node.tomcat.user
end