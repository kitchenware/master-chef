include_recipe "tomcat"
include_recipe "nginx"

directory node.nexus.path do
  owner node.tomcat.user
end

override_config = {:env => {"PLEXUS_NEXUS_WORK" => node.nexus.path}}

tomcat_instance "nexus:tomcat" do
  override override_config
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

