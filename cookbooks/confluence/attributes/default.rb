default[:confluence][:version] = "4.1.6"
default[:confluence][:url] = "http://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-#{default[:confluence][:version]}-war.tar.gz"
default[:confluence][:path][:root_path] = "/confluence"
default[:confluence][:path][:home] = "#{default[:confluence][:path][:root_path]}/home"
default[:confluence][:path][:build] = "#{default[:confluence][:path][:root_path]}/build"
default[:confluence][:location] = "/confluence"
default[:confluence][:tomcat] = {
  :name => 'confluence',
  :env => {
    'JAVA_OPTS' => '-XX:MaxPermSize=256m -Xmx1024m -Xms256m',
    'TOMCAT5_SECURITY' => 'no',
  }
}
default[:confluence][:database] = {
  :host => 'localhost',
  :username => 'confluence',
  :database => 'confluence',
}