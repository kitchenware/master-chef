
default[:gitlab][:gitolite] = {
  :url => "git://github.com/gitlabhq/gitolite.git",
  :reference => "gl-v304",
  :path => "/opt/gitolite",
  :repositories => "/opt/repositories",
  :user => "git",
}

default[:gitlab][:location] = "/"
default[:gitlab][:hostname] = %x{hostname}.strip
default[:gitlab][:https] = true

default[:gitlab][:gitlab] = {
  :url => "git://github.com/gitlabhq/gitlabhq.git",
  :reference => "stable",
  :path => "/opt/gitlab",
  :user => "gitlab",
}

default[:gitlab][:database] = {
  :host => "localhost",
  :database => "gitlab",
  :username => "gitlab",
  :adapter => "mysql2",
}