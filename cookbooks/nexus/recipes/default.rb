include_recipe "tomcat"
include_recipe "nginx"

build_dir = "#{node.nexus.path.build}/nexus-#{node.nexus.version}"


tomcat_instance "nexus:tomcat" do
  war_url "#{node.nexus.war_url}"
  war_location node.nexus.location
end

tomcat_nexus_http_port = tomcat_config("nexus:tomcat")[:connectors][:http][:port]

nginx_add_default_location "nexus" do
  content <<-EOF

  location #{node.nexus.location} {
    proxy_pass http://tomcat_nexus_upstream;
    proxy_read_timeout 600s;
    break;
  }

EOF
  upstream <<-EOF
  upstream tomcat_nexus_upstream {
  server 127.0.0.1:#{tomcat_nexus_http_port} fail_timeout=0;
}
  EOF
end

