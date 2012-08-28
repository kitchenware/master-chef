
module FindResourceHelper

  def find_resources_by_name_pattern pattern
    run_context.resource_collection.select do |resource|
      resource.name =~ pattern
    end
  end

  def find_resources_by_class_pattern pattern
    run_context.resource_collection.select do |resource|
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