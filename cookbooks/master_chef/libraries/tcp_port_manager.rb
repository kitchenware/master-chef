
module TcpPortManager

  def allocate_tcp_port
    range = node.tcp_port_manager.range
    port = local_storage_read "tcp_port_manager:last_used"
    port = range.begin unless port
    port = port + 1
    local_storage_store "tcp_port_manager:last_used", port
    port
  end

end

class Chef::Recipe
  include TcpPortManager
end

class Chef::Resource
  include TcpPortManager
end

class Chef::Provider
  include TcpPortManager
end