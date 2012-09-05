class Chef::Provider::Service

  def action_delayed_restart
    @new_resource.notifies :restart, @new_resource.resources(:service => @new_resource.name)
    @new_resource.updated_by_last_action true
  end

end

class Chef::Resource::Service

  alias_method :initialize_old, :initialize

  def initialize(name, run_context=nil)
    initialize_old(name, run_context)
    @allowed_actions.push(:delayed_restart)
  end

end

module ServiceHelper

  @@service_before_start = Dir.entries('/etc/init.d').reject{|x| x == '.' || x == '..'}

  def auto_compute_action
    # why stop on new service : because the default configuration of a service can lock some resources
    # like port 80 and can break start of another service, which want to access to this resource
    # and which is not yet restarted
    # why restart on new service (and not just delayed start) : because if service is new,
    # it's probable that some config files will be deployed, and a restart command will be issued
    # some services like tomcat does not support very well to be started and immediately after restarted
    @@service_before_start.include?(self.name) ? [:enable, :start] : [:enable, :stop, :delayed_restart]
  end

end

class Chef::Resource
  include ServiceHelper
end
