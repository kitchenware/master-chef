
class Chef
  class Resource
    class DelayedExec < Chef::Resource

      def initialize(*args)
        super
        @resource_name = :delayed_exec
        @action = :wait
        @allowed_actions.push(:wait)
        @allowed_actions.push(:run)
      end

      def block(&block)
        if block_given? and block
          @block = block
        else
          @block
        end
      end
      
    end
  end
end

class Chef
  class Provider
    class DelayedExec < Chef::Provider

      def load_current_resource
        true
      end

      def action_run
        @new_resource.block.call
        @new_resource.updated_by_last_action true
      end

      def action_wait
        @new_resource.notifies :run, @new_resource.resources(:delayed_exec => @new_resource.name)
        @new_resource.updated_by_last_action true
      end

    end
  end
end
