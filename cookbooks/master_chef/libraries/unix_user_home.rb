
module UnixUserHome

  def get_home user_name
    u = find_resources_by_class_pattern(/^Chef::Resource::User/).find{|u| u.name == user_name}
    dir = u  && u.home ? u.home : ""
    dir = %x{cat /etc/passwd | grep "^#{user_name}:" | awk -F: '{print $6}'}.strip if dir.empty?
    dir = node.users[user_name].home if dir.empty? && node[:users] && node[:users][user_name] && node[:users][user_name][:home]
    dir = "/home/#{user_name}" if dir.empty?
    dir
  end

end

class Chef::Recipe
  include UnixUserHome
end

class Chef::Resource
  include UnixUserHome
end

class Chef::Provider
  include UnixUserHome
end

class Chef::ResourceDefinition
  include UnixUserHome
end