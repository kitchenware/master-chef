include_recipe "mysql"
include_recipe "tomcat"
include_recipe "nginx"

[node.confluence.path.root_path, node.confluence.path.home, node.confluence.path.build].each do |dir|
  directory dir do
    owner node.tomcat.user
  end
end

mysql_database "confluence:database"

db_config = mysql_config "confluence:database"

Chef::Log.info "************************************************************"
Chef::Log.info "Mysql database for confluence"
Chef::Log.info "Host          : #{db_config[:host]}"
Chef::Log.info "Database name : #{db_config[:database]}"
Chef::Log.info "User          : #{db_config[:username]}"
Chef::Log.info "Password      : #{db_config[:password]}"
Chef::Log.info "************************************************************"

tar_gz = "#{node.confluence.version}.tar.gz"
build_dir = "#{node.confluence.path.build}/confluence-#{node.confluence.version}"
bash "download confluence"  do
  user node.tomcat.user
  code "cd #{node.confluence.path.build} && curl --location #{node.confluence.url} -o #{tar_gz} && tar xzf #{tar_gz}"
  not_if "[ -d #{build_dir} ]"
end

directory "#{build_dir}/edit-webapp/WEB-INF/classes"  do
  owner node.tomcat.user
  recursive true  
end

template "#{build_dir}/edit-webapp/WEB-INF/classes/confluence-init.properties" do
  owner node.tomcat.user
  source "confluence-init.properties.erb"
  variables :home => node.confluence.path.home
end

war_file = "#{build_dir}/dist/confluence-#{node.confluence.version}.war"
bash "build confluence" do
  user node.tomcat.user
  code "cd #{build_dir} && sh build.sh clean && sh build.sh"
  not_if "[ -f #{war_file} ]"
end

tomcat_instance "confluence:tomcat" do
  war_url "file://#{war_file}"
  war_location node.confluence.location
end

tomcat_confluence_http_port = tomcat_config("confluence:tomcat")[:connectors][:http][:port]

nginx_add_default_location "confluence" do
  content <<-EOF

  location #{node.confluence.location} {
    proxy_pass http://tomcat_confluence_upstream;
    proxy_read_timeout 600s;
    break;
  }

EOF
  upstream <<-EOF
  upstream tomcat_confluence_upstream {
  server 127.0.0.1:#{tomcat_confluence_http_port} fail_timeout=0;
}
  EOF
end
