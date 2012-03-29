
define :tomcat_instance, {
  :env => {},
  :connectors => nil,
  :control_port => nil,
  :war_url => nil,
  :war_name => nil,
} do

  tomcat_instance_params = params

  raise "Please specify connectors with tomcat_instance" unless tomcat_instance_params[:connectors]
  raise "Please specify control_port with tomcat_instance" unless tomcat_instance_params[:control_port]

  catalina_base = "#{node.tomcat.instances_base}/#{tomcat_instance_params[:name]}"
  
  [
    "#{catalina_base}",
    "#{catalina_base}/temp",
    "#{catalina_base}/webapps",
    "#{catalina_base}/work",
    "#{node.tomcat.log_dir}/#{tomcat_instance_params[:name]}"
    ].each do |d|
    directory d do
      owner node.tomcat.user
    end
  end

  bash "copy config #{catalina_base}/conf" do
    user node.tomcat.user
    code "cp -r #{node.tomcat.catalina_home}/conf #{catalina_base}/conf && rm #{catalina_base}/conf/server.xml"
    not_if "[ -d #{catalina_base}/conf ]"
  end

  link "#{catalina_base}/logs" do
    owner node.tomcat.user
    to "#{node.tomcat.log_dir}/#{tomcat_instance_params[:name]}"
  end
  
  template "/etc/init.d/#{tomcat_instance_params[:name]}" do
    cookbook "tomcat"
    source "init_d.erb"
    mode 0755
    variables({
      :catalina_base => catalina_base,
      :catalina_home => node.tomcat.catalina_home,
      :name => tomcat_instance_params[:name],
      :user => node.tomcat.user,
      :group => node.tomcat.group,
      })
  end

  service "#{tomcat_instance_params[:name]}" do
    supports :status => true, :restart => true, :reload => true, :graceful_restart => true
    action [ :enable, :start ]
  end

  template "#{catalina_base}/conf/env" do
    cookbook "tomcat"
    source "env.erb"
    owner "tomcat"
    mode 0644
    variables :env => tomcat_instance_params[:env]
    notifies :restart, resources(:service => tomcat_instance_params[:name])
  end 

  template "#{catalina_base}/conf/server.xml" do
    cookbook "tomcat"
    source "server.xml.erb"
    owner node.tomcat.user
    variables :connectors => tomcat_instance_params[:connectors], :control_port => tomcat_instance_params[:control_port]
    notifies :restart, resources(:service => tomcat_instance_params[:name])
  end

  if tomcat_instance_params[:war_name] && tomcat_instance_params[:war_url]
    package "curl"
    war_file = "#{tomcat_instance_params[:war_name]}.war"
    war_full_file = "#{catalina_base}/webapps/#{war_file}"
    user node.tomcat.user
    bash "install war from url #{tomcat_instance_params[:name]}" do
      code "curl -s --location #{tomcat_instance_params[:war_url]} -o /tmp/#{war_file} && mv /tmp/#{war_file} #{war_full_file}"
      not_if "[ -f #{war_full_file} ]"
    end
  end

end