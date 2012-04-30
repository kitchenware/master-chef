module TomcatHelper

  def tomcat_config key
    config = extract_config key

    instance_name = config[:name]
    
    raise "Please specify name in tomcat config #{key}" unless instance_name

    unless config[:control_port]
      config[:control_port] = local_storage_read "tomcat:control_port:#{instance_name}" do
        allocate_tcp_port
      end
    end

    if !config[:connectors] || config[:connectors].size == 0
      http_port = local_storage_read "tomcat:http_port:#{instance_name}" do
       allocate_tcp_port
      end
      config[:connectors] = {
        :http => {
          :port => http_port,
          :address => "127.0.0.1",
        }
      } 
    end

    config
  end

end

class Chef::Recipe
  include TomcatHelper
end

class Chef::Resource
  include TomcatHelper
end

class Chef::Provider
  include TomcatHelper
end