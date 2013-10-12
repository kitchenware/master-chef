
default[:gitlab][:gitlab_shell] = {
  :url => "git://github.com/gitlabhq/gitlab-shell.git",
  :reference => "v1.7.1",
  :repositories => "/opt/repositories",
  :user => "git",
  :group => "git",
  :path => "/opt/gitlab-shell",
}

default[:gitlab][:config] = {
  :location => "/",
  :hostname => %x{hostname}.strip,
  :https => false,
  :port => 80,
  :email_from => "notify@localhost",
  :default_projects_limit => 10,
  :default_can_create_group => true,
  :signup_enabled => false,
}

default[:gitlab][:gitlab] = {
  :url => "git://github.com/gitlabhq/gitlabhq.git",
  :reference => "b595503968078e583ed2715840095719d72e4f3b", # branch 6-1-stable
  :path => "/opt/gitlab",
  :user => "gitlab",
}

default[:gitlab][:database] = {
  :host => "localhost",
  :database => "gitlab",
  :username => "gitlab",
  :mysql_wrapper => {
    :file => default[:gitlab][:gitlab][:path] + "/shared/mysql.sh",
    :owner => "gitlab"
  }
}