
define :haproxy_vhost, {
  :source => nil,
  :cookbook => nil,
  :variables => nil,
} do

  haproxy_vhost_params = params

  raise "Missing source params for haproxy_vhost" unless haproxy_vhost_params[:source]

  incremental_template_part haproxy_vhost_params[:name] do
    target "/etc/haproxy/haproxy.cfg"
    source haproxy_vhost_params[:source]
    cookbook haproxy_vhost_params[:cookbook] if haproxy_vhost_params[:cookbook]
    variables haproxy_vhost_params[:variables] if haproxy_vhost_params[:variables]
  end

end
