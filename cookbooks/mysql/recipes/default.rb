
if (node.mysql.use_percona || node.mysql.add_percona_repo) && node.apt.master_chef_add_apt_repo

  add_apt_repository "percona_repo" do
    url "http://repo.percona.com/apt"
    key "8507EFA5"
    key_server "keys.gnupg.net"
  end

end

client_package_name = node.mysql[:client_package_name] || (node.mysql.use_percona ? node.mysql.percona_client_package_name : node.mysql.client_package_name)
Chef::Log.info "Using mysql client package #{client_package_name}"

package client_package_name
