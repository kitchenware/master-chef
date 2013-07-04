
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