
unless defined?(CHEF_SERVICE_ALREADY_IMPROVED)

  class Chef::Provider::Service

    alias_method :action_restart_old, :action_restart
    alias_method :action_reload_old, :action_reload

    @@already_restarted = []

    def action_reload
      if @@already_restarted.include? @new_resource.name
        Chef::Log.info "Service #{@new_resource.name} already restarted, skipping reload"
      else
        action_reload_old
      end
    end

    def action_restart
      @@already_restarted << @new_resource.name
      action_restart_old
    end

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

  CHEF_SERVICE_ALREADY_IMPROVED = 1

end


module ServiceHelper

  @@service_before_start = Dir.entries('/etc/init.d').reject{|x| x == '.' || x == '..'} + %x{which systemctl && systemctl | sed 1d | sed 1d | awk '{print $1}'}.force_encoding('UTF-8').split("\n").map{|x| x.gsub(/\.service$/, '')}

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
