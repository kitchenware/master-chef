
if node.mysql.use_percona && node.apt.master_chef_add_apt_repo

  add_apt_repository "ppa_nginx" do
    url "http://repo.percona.com/apt"
    key "1C4CBDCDCD2EFD2A"
    key_server "keys.gnupg.net"
  end

end


client_package_name = node.mysql.use_percona ? node.mysql.percona_client_package_name : node.mysql.client_package_name
Chef::Log.info "Using mysql client package #{client_package_name}"

package client_package_name
