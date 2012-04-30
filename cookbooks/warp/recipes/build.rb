
package "s3cmd"

package "build-essential"

include_recipe "java"

ruby_user "build" do
  install_rbenv true
end

sudo_sudoers_file "build" do
  content "build ALL=(ALL) NOPASSWD:ALL"
end