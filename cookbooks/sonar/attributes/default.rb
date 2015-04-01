default[:sonar][:location] = "/sonar"
default[:sonar][:version] = "5.0.1"
default[:sonar][:zip_url] = "http://dist.sonar.codehaus.org/sonarqube-#{default[:sonar][:version]}.zip"
default[:sonar][:path] = "/opt/sonar"
default[:sonar][:user] = "sonar"
default[:sonar][:database] = {
  :host => 'localhost',
  :username => 'sonar',
  :database => 'sonar',
}
