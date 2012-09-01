class Chef::Provider::Service

  def action_delayed_start
    @new_resource.notifies :start, @new_resource.resources(:service => @new_resource.name)
    @new_resource.updated_by_last_action true
  end

end

class Chef::Resource::Service

  alias_method :initialize_old, :initialize

  def initialize(name, run_context=nil)
    initialize_old(name, run_context)
    @allowed_actions.push(:delayed_start)
  end

end

module ServiceHelper

  @@service_before_start = Dir.entries('/etc/init.d').reject{|x| x == '.' || x == '..'}

  def auto_compute_action
    @@service_before_start.include?(self.name) ? [:enable, :delayed_start] : [:enable, :stop, :delayed_start]
  end

end

class Chef::Resource
  include ServiceHelper
end
