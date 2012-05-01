default[:redmine][:user] = "redmine"
default[:redmine][:directory] = "/home/redmine/redmine"
default[:redmine][:version] = "1.3.1"
default[:redmine][:git_url] = "git://github.com/edavis10/redmine.git"
default[:redmine][:location] = "/redmine"
default[:redmine][:database] = {
  :host => "localhost",
  :username => "redmine",
  :database => "redmine",
}
