module RailsAppHelper

  def unicorn_rails_app_path name
    node.unicorn_rails_app[name]
  end

end

class Chef::Recipe
  include RailsAppHelper
end

class Chef::Resource
  include RailsAppHelper
end

class Chef::Provider
  include RailsAppHelper
end

class Chef::ResourceDefinition
  include RailsAppHelper
end