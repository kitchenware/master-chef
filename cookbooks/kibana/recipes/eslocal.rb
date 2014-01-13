
include_recipe "nginx"

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

nginx_add_default_location "bind_to_es" do
  content <<-EOF

  location ~ ^/_aliases$ {
    proxy_pass http://elastic_search_upstream;
    proxy_read_timeout 90;
  }

  location ~ ^/.*/_search$ {
    proxy_pass http://elastic_search_upstream;
    proxy_read_timeout 90;
  }

EOF
  upstream <<-EOF
upstream elastic_search_upstream {
  server 127.0.0.1:9200 fail_timeout=0;
}
  EOF
end

template "#{node.kibana3.directory}/current/config.js" do
  source "kibana3/config.js.erb"
end