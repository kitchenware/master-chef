include_recipe "mysql"
include_recipe "tomcat"
include_recipe "nginx"

node.sonar.zip_url.match /.+(sonar-\d+\.\d+).zip/
sonar_file_name = $1

mysql_database "sonar" do
  password "sonar"
end

execute "install sonar home" do  
  command "cd /home/chef/ && wget #{node.sonar.zip_url} && unzip /home/chef/#{sonar_file_name}.zip && rm -f /home/chef/#{sonar_file_name}.zip"
  not_if "[ -d /home/chef/#{sonar_file_name} ]"
end

directory "/home/chef/#{sonar_file_name}" do
  owner node.tomcat.user
  recursive true
end

execute "change sonar home owner" do
  command "chown -R #{node.tomcat.user} /home/chef/#{sonar_file_name}"
end

template "/home/chef/#{sonar_file_name}/conf/sonar.properties" do
  mode 0644
  source "sonar.properties.erb"
end

tomcat_instance "sonar" do
  env({
    'TOMCAT5_SECURITY' => 'no',
    'SONAR_HOME' => "/home/chef/#{sonar_file_name}",
  })
  connectors({
    "http" => {
      "port" => 8080,
      "address" => "127.0.0.1",
      "URIEncoding" => "UTF-8",
      },
    })
  control_port 8005
  war_url "https://s3-eu-west-1.amazonaws.com/software-factory-2/sonar.war"
  war_name "#{node.sonar.location[1..-1]}"
end

nginx_add_default_location "sonar" do
  content <<-EOF

  location #{node.sonar.location} {
    proxy_pass http://tomcat_sonar_upstream;
    break;
  }

EOF
  upstream <<-EOF
  upstream tomcat_sonar_upstream {
  server 127.0.0.1:8080 fail_timeout=0;
}
  EOF
end
