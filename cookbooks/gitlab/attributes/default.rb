
default[:gitlab][:gitolite] = {
  :url => "git://github.com/gitlabhq/gitolite.git",
  :reference => "gl-v304",
  :path => "/opt/gitolite",
  :repositories => "/opt/repositories",
  :user => "git",
}

default[:gitlab][:location] = "/"
default[:gitlab][:hostname] = %x{hostname}.strip
default[:gitlab][:https] = false
default[:gitlab][:port] = 80

default[:gitlab][:gitlab] = {
  :url => "git://github.com/gitlabhq/gitlabhq.git",
  :reference => "b2df61d85ab295a9ba4585f667537a9afc3efc6a",
  :path => "/opt/gitlab",
  :user => "gitlab",
}

default[:gitlab][:database] = {
  :host => "localhost",
  :database => "gitlab",
  :username => "gitlab",
  :adapter => "mysql2",
  :mysql_wrapper => {
    :file => default[:gitlab][:gitlab][:path] + "/shared/mysql.sh",
  }
}