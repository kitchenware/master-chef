
package "vim"

bash "Use vim.basic as default editor" do
  user "root"
  code <<-EOF
  update-alternatives --set editor /usr/bin/vim.basic
  EOF
  not_if "update-alternatives --display editor | grep 'link currently points' | grep vim.basic"
end

link "/etc/localtime" do
  to "/usr/share/zoneinfo/UTC"
end

include_recipe "base::bash"
include_recipe "base::sshd"
include_recipe "base::ntp"