
module FindResourceHelper

  # resource definition does not have access to run_context
  # we save run_context when whe have it for using it in next resource_definition

  def find_resources_by_name_pattern pattern
    @@resource_helper_run_context = run_context if run_context.class == Chef::RunContext
    @@resource_helper_run_context.resource_collection.select do |resource|
      resource.name =~ pattern
    end
  end

  def find_resources_by_class_pattern pattern
    @@resource_helper_run_context = run_context if run_context.class == Chef::RunContext
    @@resource_helper_run_context.resource_collection.select do |resource|
      resource.class =~ pattern
    end
  end

end

class Chef::Recipe
  include FindResourceHelper
end

class Chef::Resource
  include FindResourceHelper
end

class Chef::Provider
  include FindResourceHelper
end

class Chef::ResourceDefinition
  include FindResourceHelper
end