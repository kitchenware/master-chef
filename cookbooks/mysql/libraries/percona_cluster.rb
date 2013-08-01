
class PerconaCluster

  def initialize config
    @config = config
  end

  def converge config_updated = false
    Chef::Log.info "******************************************************************"
    Chef::Log.info "*** Managing percona cluster #{@config["name"]}"
    Chef::Log.info "*** Nodes #{@config["nodes"].join(' , ')}"
    Chef::Log.info "*** Local node #{@config["local_node"]}"
    Chef::Log.info "*** Is master #{@config["is_master"]}"
    Chef::Log.info "*** Config updated #{config_updated}"
    Chef::Log.info "******************************************************************"
    if config_updated && ! is_cluster_activated?
      if @config["is_master"]
        if other_nodes_ready
          Chef::Log.info "Cluster seems to exists"
          restart
          wait_cluster_sync
        else
          Chef::Log.info "Boostraping new cluster"
          restart "stop"
          restart "bootstrap-pxc"
          wait_cluster_sync
          Chef::Log.info "Creating replication user"

          @config["mysql_commands"].each do |cmd|
            Chef::Log.info "Running #{cmd}"
            code, result = mysql_command cmd
            raise "Unable to create replication user : #{result}" unless code == 0
          end

          Chef::Log.info "Cluster boostraped"

          wait "other nodes", 3600, 10 do
            code, result = mysql_command "show status like 'wsrep%';"
            raise "Unable to get replication status : #{result}" unless code == 0
            extract_key_value(result, "wsrep_incoming_addresses").split(',').size > 2
          end

          wait "other nodes mysql port ready", 3600, 10 do
            other_nodes_ready 2
          end

          Chef::Log.info "Rebooting in standard configuration"
          restart
          wait_cluster_sync
        end
      else
        Chef::Log.info "First boot on cluster slave"
        wait "other nodes", 3600, 10 do
          other_nodes_ready
        end
        restart
        wait_cluster_sync
      end
    else
      if config_updated
        Chef::Log.info "Config changed, restarting"
        restart
        wait_cluster_sync
      end
    end
    Chef::Log.info "******************************************************************"
    Chef::Log.info "*** End of percona cluster configuration"
    Chef::Log.info "******************************************************************"
  end

  def wait_cluster_sync
    wait "cluster synchronisation", 180, 5 do
      is_cluster_sync?
    end
  end

  def other_nodes_ready number_of_nodes = 1
    nodes_ready = 0
    @config["nodes"].reject{|x| x == @config["local_node"]}.each do |x|
      if port_open?(x, 3306) && port_open?(x, 4567)
        Chef::Log.info "Node #{x} is ready"
        nodes_ready += 1
      end
    end
    nodes_ready >= number_of_nodes
  end

  def restart command = "restart"
    raise "Unable to restart mysql" unless Kernel.system("/etc/init.d/mysql #{command}")
  end

  def is_cluster_activated?
    code, content = mysql_command "show status like 'wsrep%';"
    return false unless code == 0
    extract_key_value(content, "wsrep_connected") == "ON"
  end

  def is_cluster_sync?
    code, content = mysql_command "show status like 'wsrep%';"
    return false unless code == 0
    extract_key_value(content, "wsrep_local_state_comment") == "Synced" && extract_key_value(content, "wsrep_ready") == "ON" && extract_key_value(content, "wsrep_connected") == "ON"
  end

  def port_open? host, port
    %x{nc -vz #{host} #{port} 2> /dev/null}
    $?.exitstatus == 0
  end

  def extract_key_value content, key
    content.split("\n").each do |x|
      k, v = x.split
      return v if k == key
    end
    raise "Unable to find key #{key}"
  end

  def wait title, timeout, interval
    stop = Time.now.to_i + timeout
    Chef::Log.info "Waiting #{title}"
    while stop > Time.now.to_i
      if yield
        puts ""
        puts "End of waiting #{title}"
        return
      end
      $stdout.write "."
      $stdout.flush
      sleep interval
    end
    raise "Timeout while waiting #{title}"
  end

  def mysql_command command
    result = %x{echo \"#{command}\" | mysql --user=root --password=#{@config["root_password"]} --raw 2>&1}
    return $?.exitstatus, result
  end

end