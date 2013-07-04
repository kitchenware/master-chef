
include_recipe "nginx"

capistrano_app node.kibana3.directory do
  user "root"
end

git_clone "#{node.kibana3.directory}/current" do
  user "root"
  reference node.kibana3.version
  repository node.kibana3.git
end

directory "#{node.kibana3.directory}/shared/www"

link "#{node.kibana3.directory}/shared/www/#{node.kibana3.location}" do
  to "#{node.kibana3.directory}/current"
end

nginx_add_default_location node.kibana3.location do
  content <<-EOF

  location #{node.kibana3.location} {
    root #{node.kibana3.directory}/shared/www;
  }

EOF
end

