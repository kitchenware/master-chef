
module UnixUserHome

  def get_home user_name
    dir = %x{cat /etc/passwd | grep "^#{user_name}:" | awk -F: '{print $6}'}.strip
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