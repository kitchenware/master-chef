default[:nginx][:deploy_default_config] = true

default[:nginx][:ubuntu_ppa_channel] = 'stable'

default[:nginx][:default_root] = "/var/www/nginx-default"

default[:nginx][:default_vhost] = {
  :listen => '0.0.0.0:80',
  :virtual_host => nil,
  :enabled => true,
  :locations => [],
  :options => {
    :gzip => true,
    :gzip_comp_level => 3,
    :gzip_types => [
      "text/plain",
      "text/css",
      "application/x-javascript",
      "text/xml",
      "application/xml",
      "application/xml+rss",
      "text/javascript",
      "application/atom+xml",
      ],
    :gzip_static => false,
    :auto_index => false,
    :static_error_pages => true,
  }
}

default[:nginx][:config] = {
  :worker_connections => 100000,
  :max_upload_size => '50m',
  :default_log_format => 'combined',
  :log_formats => {
    :main => "'$remote_addr - $host - [$time_local] ' '\"$request\" $status $body_bytes_sent $request_time \"$http_referer\" ' '\"$http_user_agent\"'"
  },
}

default[:nginx][:package_name] = "nginx"
