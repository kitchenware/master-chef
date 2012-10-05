
include_recipe "libzmq"

execute_version "install jzmq" do
  user root
  command "cd /tmp && curl --location #{node.warp.warp_src}/#{node.libzmq.jzmq.warp_file} -o #{node.libzmq.jzmq.warp_file} && sh #{node.libzmq.jzmq.warp_file} && rm #{node.libzmq.jzmq.warp_file}"
  version node.libzmq.jzmq.version
  file_storage "#{node.libzmq.jzmq.directory}/.version"
end
