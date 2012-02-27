include_recipe "java"

package "libapr1"

base_user node.tomcat.user do
  home node.tomcat.home
end

bash "install tomcat via warp" do
  user node.tomcat.user
  code "cd #{node.tomcat.home} && wget #{node.warp.warp_src}/#{node.tomcat.warp_file} && sh #{node.tomcat.warp_file} && rm #{node.tomcat.warp_file}"
  not_if "[ -d #{node.tomcat.home}/#{node.tomcat.warp_file =~ /^(.*)\.warp/; $1} ]"
end
