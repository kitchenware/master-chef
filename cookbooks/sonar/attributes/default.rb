default[:sonar][:location] = "/sonar"
default[:sonar][:version] = "3.0.1"
default[:sonar][:zip_url] = "http://dist.sonar.codehaus.org/sonar-#{default[:sonar][:version]}.zip"
default[:sonar][:path][:root_path] = "/sonar"
default[:sonar][:path][:build] = "#{default[:sonar][:path][:root_path]}"
default[:sonar][:tomcat] = {
  :name => 'sonar',
  :env => {
    'JAVA_OPTS' => '-XX:MaxPermSize=256m -Xmx1024m -Xms256m',
  }
}
default[:sonar][:database] = {
  :host => 'localhost',
  :username => 'sonar',
  :database => 'sonar',
}