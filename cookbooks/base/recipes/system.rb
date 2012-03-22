
package "vim"
package "unzip"

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
include_recipe "base::procps"
include_recipe "base::disable_ipv6"
include_recipe "base::resolv_conf"
include_recipe "base::ssh_keys"
include_recipe "base::additional"