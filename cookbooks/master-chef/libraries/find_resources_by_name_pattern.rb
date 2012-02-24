
module FindResourceByNamePatternHelper
  
  def find_resources_by_name_pattern pattern
    run_context.resource_collection.select do |resource|
      resource.name =~ pattern
    end
  end
  
end

class Chef::Recipe
  include FindResourceByNamePatternHelper
end

class Chef::Resource
  include FindResourceByNamePatternHelper
end

class Chef::Provider
  include FindResourceByNamePatternHelper
end

class Chef::ResourceDefinition
  include FindResourceByNamePatternHelper
end