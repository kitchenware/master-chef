
class ServiceErrorHandler < Chef::Handler
  
  def initialize(service_name, pattern_for_process_kill)
    @service_name = service_name
    @pattern_for_process_kill = pattern_for_process_kill
  end
  
  def report
    return unless exception.to_s =~ /service\[#{@service_name}\]/
    puts "Starting service error handler for #{@service_name}"
    puts "*********************************************************"
    puts "Searching for config files to be deployed"
    all_resources.each do |r|
      notifs = r.delayed_notifications + r.immediate_notifications
      notifs.each do |n|
        if n.resource.name == @service_name && [:restart, :reload, :delayed_restart].include?(n.action)
          action = r.action.to_sym
          puts "******** Find resource to deploy : #{r.name}, action #{action}"
          r.run_action action
        end
      end
    end
    puts "*********************************************************"
    result = restart
    return if result == 0
    puts "Trying to kill processes : #{@pattern_for_process_kill}"
    puts %x{pkill -f '#{@pattern_for_process_kill}'}
    restart
  end

  def restart
    puts "Trying to restart service"
    puts %x{/etc/init.d/#{@service_name} start}
    result = $?
    puts "Result : #{result == 0 ? "OK" : "KO"} (#{result})"
    puts "*********************************************************"
    result
  end
end

