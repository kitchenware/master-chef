
package "s3cmd"

package "build-essential"

include_recipe "java"

ruby_user "build" do
  install_rbenv true
end

sudo_sudoers_file "build" do
  content "build ALL=(ALL) NOPASSWD:ALL"
end

template "#{get_home "build"}/upload.sh" do
  owner "build"
  mode 0755
  source "upload.sh.erb"
  variables :bucket => "warp-repo"
end