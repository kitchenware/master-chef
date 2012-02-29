include_recipe "mysql"
include_recipe "tomcat"
include_recipe "nginx"

[node.confluence.root, node.confluence.home, node.confluence.build].each do |dir|
  directory dir do
    owner node.tomcat.user
  end
end

tar_gz = "#{node.confluence.version}.tar.gz"
build_dir = "#{node.confluence.build}/confluence-#{node.confluence.version}"
bash "download confluence"  do
  user node.tomcat.user
  code "cd #{node.confluence.build} && curl --location #{node.confluence.url} -o #{tar_gz} && tar xzf #{tar_gz}"
  not_if "[ -d #{build_dir} ]"
end

directory "#{build_dir}/edit-webapp/WEB-INF/classes"  do
  owner node.tomcat.user
  recursive true  
end

template "#{build_dir}/edit-webapp/WEB-INF/classes/confluence-init.properties" do
  owner node.tomcat.user
  source "confluence-init.properties.erb"
  variables :home => node.confluence.home
end

war_file = "#{build_dir}/dist/confluence-#{node.confluence.version}.war"
bash "build confluence" do
  user node.tomcat.user
  code "cd #{build_dir} && sh build.sh clean && sh build.sh"
  not_if "[ -f #{war_file} ]"
end

tomcat_instance "confluence" do
  env({
    'TOMCAT5_SECURITY' => 'no',
   }.merge(node.confluence.env))
  connectors({
    "http" => {
      "port" => 8081,
      "address" => "127.0.0.1"},
    })
  control_port 8006
  war_url "file://#{war_file}"
  war_name "#{node.confluence.location[1..-1]}"
end

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
  server 127.0.0.1:8081 fail_timeout=0;
}
  EOF
end

confluence_password = PasswordGenerator.generate("/.confluence_password", 32)

mysql_database "confluence" do
  password confluence_password
end