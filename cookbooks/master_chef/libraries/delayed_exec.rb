
class Chef
  class Resource
    class DelayedExec < Chef::Resource

      def initialize(*args)
        super
        @resource_name = :delayed_exec
        @action = :wait
        @allowed_actions.push(:wait)
        @allowed_actions.push(:run)
        @after_block_notifies = []
      end

      def after_block_notifies after_block_notifies_action = nil, after_block_notifies_resource = nil
        if after_block_notifies_action && after_block_notifies_resource
          @after_block_notifies << [after_block_notifies_action, after_block_notifies_resource]
        end
        @after_block_notifies
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
        result = @new_resource.block ? @new_resource.block.call : true
        if result == true && @new_resource.after_block_notifies.size > 0
          @new_resource.after_block_notifies.each do |r|
            @new_resource.notifies(r[0], r[1])
          end
        end
        @new_resource.updated_by_last_action true
      end

      def action_wait
        @new_resource.notifies :run, @new_resource.resources(:delayed_exec => @new_resource.name)
        @new_resource.updated_by_last_action true
      end

    end
  end
end
