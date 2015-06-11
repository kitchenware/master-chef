base_user node.etcd.user

directory node.etcd.home do
  owner node.etcd.user
  group node.etcd.user
  mode 0755
end

execute "download etcd #{node.etcd.version} and uncompress it" do
  user "root"
  command "cd /tmp && curl -s -f -L #{node.etcd.download_url} -o etcd-v#{node.etcd.version}-linux-amd64.tar.gz && tar -xzvf etcd-v#{node.etcd.version}-linux-amd64.tar.gz && mv etcd-v#{node.etcd.version}-linux-amd64 #{node.etcd.path} && chown -R #{node.etcd.user} #{node.etcd.home}"
  not_if "[ -d #{node.etcd.path} ]"
end

basic_init_d "etcd" do
  daemon "#{node.etcd.path}/etcd"
  user node.etcd.user
  directory_check [node.etcd.path]
  working_directory node.etcd.path
  options "--data-dir #{node.etcd.data_dir}"
end


