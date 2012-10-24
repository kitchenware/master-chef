
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
default[:gitlab][:mail_from] = "notify@localhost"

default[:gitlab][:gitlab] = {
  :url => "git://github.com/gitlabhq/gitlabhq.git",
  :reference => "v3.0.3",
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