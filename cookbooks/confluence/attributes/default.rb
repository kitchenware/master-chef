default[:confluence][:version] = "4.1.6"
default[:confluence][:url] = "http://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-#{default[:confluence][:version]}-war.tar.gz"
default[:confluence][:root] = "/confluence"
default[:confluence][:home] = "#{default[:confluence][:root]}/home"
default[:confluence][:build] = "#{default[:confluence][:root]}/build"
default[:confluence][:location] = "/confluence"
default[:confluence][:env] = {
  'JAVA_OPTS' => '-XX:MaxPermSize=256m -Xmx1024m -Xms256m'
}