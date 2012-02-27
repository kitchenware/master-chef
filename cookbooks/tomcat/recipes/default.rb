include_recipe "java"

package "libapr1"

bash "install tomcat via warp" do
  not_if "[ -d /opt/tomcat6 ]"