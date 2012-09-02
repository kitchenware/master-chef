include_recipe "java"
include_recipe "nginx"

base_user node.jboss.user do
  home node.jboss.home
end

bash "install jboss with official zip" do
  user node.jboss.user
  code "cd #{node.jboss.home} && curl --location #{node.jboss.zip_file} -o && unzip jboss-as-#{node.jboss.version}.zip && jboss-as-#{node.jboss.version}.zip && rm jboss-as-#{node.jboss.version}.zip"
  not_if "[ -d #{node.jboss.jboss_home} ]"
end

directory "/etc/jboss-as/" do
  recursive true
  owner node.jboss.user
end

directory node.jboss.log_dir do
  owner node.jboss.user
end

template "#{node.jboss.jboss_home}/standalone/configuration/standalone.xml" do 
  mode 0644
  source "standalone.xml"
end

template "#{node.jboss.jboss_home}/standalone/configuration/mgmt-users.properties" do 
  mode 0644
  source "mgmt-users.properties"
end

template "/etc/init.d/jboss" do
  mode 0755
  variables :jboss_home => node.jboss.jboss_home
  source "jboss-as-standalone.sh.erb"
end

template "/etc/jboss-as/jboss-as.conf" do
  mode 0644
  variables :log_dir => node.jboss.log_dir
  source "jboss-as.conf.erb"
end

service "jboss" do
  supports :status => true, :restart => true, :reload => true
  action auto_compute_action
end

nginx_add_default_location "jboss" do
  content <<-EOF

  location / {
    proxy_pass http://jboss_public_upstream;
    proxy_read_timeout 600s;
    break;
  }

EOF
  upstream <<-EOF
  upstream jboss_public_upstream {
  server 127.0.0.1:8080 fail_timeout=0;
}
  EOF
end

nginx_add_default_location "adminjboss" do
  content <<-EOF

  location /admin {
    proxy_pass http://jboss_admin_upstream;
    proxy_read_timeout 600s;
    break;
  }

EOF
  upstream <<-EOF
  upstream jboss_admin_upstream {
  server 127.0.0.1:9990 fail_timeout=0;
}
  EOF
end