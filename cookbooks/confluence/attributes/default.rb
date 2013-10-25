default[:confluence][:version] = "4.1.6"
default[:confluence][:url] = "http://downloads.atlassian.com/software/confluence/downloads/atlassian-confluence-#{default[:confluence][:version]}-war.tar.gz"
default[:confluence][:path][:root_path] = "/confluence"
default[:confluence][:path][:home] = "#{default[:confluence][:path][:root_path]}/home"
default[:confluence][:path][:build] = "#{default[:confluence][:path][:root_path]}/build"

default[:confluence][:crowd][:enabled] = false
default[:confluence][:crowd][:connector_version] = "2.2.7"
default[:confluence][:crowd][:crowd_url] = "http://crowd/crowd"
default[:confluence][:crowd][:crowd_application_name] = "confluence"
default[:confluence][:crowd][:crowd_application_password] = "confluence_password"

default[:confluence][:location] = "/confluence"
default[:confluence][:tomcat] = {
  :name => 'confluence',
  :env => {
    'JAVA_OPTS' => '-XX:MaxPermSize=256m -Xmx1024m -Xms256m',
  }
}
default[:confluence][:database] = {
  :host => 'localhost',
  :username => 'confluence',
  :database => 'confluence',
}