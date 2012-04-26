include_recipe "tomcat"
include_recipe "nginx"

tomcat_instance "nexus" do
  env({
    'TOMCAT5_SECURITY' => 'no',
  })
  connectors({
    "http" => {
      "port" => 8080,
      "address" => "127.0.0.1",
      "URIEncoding" => "UTF-8",
      },
    })
  control_port 8005
  war_url "#{node.nexus.war_url}"
  war_name "#{node.nexus.location[1..-1]}"
end

nginx_add_default_location "nexus" do
  content <<-EOF

  location #{node.nexus.location} {
    proxy_pass http://tomcat_nexus_upstream;
    break;
  }

EOF
  upstream <<-EOF
  upstream tomcat_nexus_upstream {
  server 127.0.0.1:8080 fail_timeout=0;
}
  EOF
end
