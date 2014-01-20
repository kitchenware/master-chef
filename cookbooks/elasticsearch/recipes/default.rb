require 'net/http'

include_recipe "java"

base_user node.elasticsearch.user

optional_config = ""
init_d_code = []
init_d_code << "ulimit -n 65000\nexport JAVA_OPTS=\"#{node.elasticsearch.java_opts}\""

directory node.elasticsearch.directory_data do
  owner node.elasticsearch.user
  recursive true
end

node.elasticsearch.env_vars.each do |k, v|
  init_d_code << "export #{k}=\"#{v}\""
end

Chef::Config.exception_handlers << ServiceErrorHandler.new("elasticsearch", ".*elasticsearch.*")

basic_init_d "elasticsearch" do
  daemon "#{node.elasticsearch.directory}/bin/elasticsearch"
  user node.elasticsearch.user
  directory_check [node.elasticsearch.directory]
  options "-f " + node.elasticsearch.command_line_options
  code init_d_code.join("\n")
end

execute_version "install elasticsearch" do
  command(
    "cd /tmp && " +
    "([ ! -x /etc/init.d/elasticsearch ] || /etc/init.d/elasticsearch stop) && " +
    "rm -rf #{node.elasticsearch.directory} && " +
    "curl --location #{node.elasticsearch.url} -o #{File.basename(node.elasticsearch.url)} && " +
    "tar xvzf #{File.basename(node.elasticsearch.url)} && " +
    "mv #{File.basename(node.elasticsearch.url)[0..-8]} #{node.elasticsearch.directory} && "+
    "chown -R #{node.elasticsearch.user} #{node.elasticsearch.directory}"
  )
  environment get_proxy_environment
  version node.elasticsearch.url
  file_storage "#{node.elasticsearch.directory}/.elasticsearch_ready"
  notifies :restart, "service[elasticsearch]"
end

template "#{node.elasticsearch.directory}/config/elasticsearch.yml" do
  owner node.elasticsearch.user
  source "elasticsearch.yml.erb"
  mode '0644'
  variables :config => node.elasticsearch.to_hash, :optional_config => optional_config
  notifies :restart, "service[elasticsearch]"
end

template "#{node.elasticsearch.directory}/config/logging.yml" do
  owner node.elasticsearch.user
  source "logging.yml.erb"
  mode '0644'
  notifies :restart, "service[elasticsearch]"
end

node.elasticsearch.plugins.each do |k, v|

  next unless v[:enable]

  command = "bin/plugin -install #{v[:id]}"
  command += " --url #{v[:url]}" if v[:url]

  execute_version "install elasticsearch plugin #{k}" do
    command "cd #{node.elasticsearch.directory} && #{command}"
    environment get_proxy_environment
    version "#{k}_#{v[:id]}"
    file_storage "#{node.elasticsearch.directory}/.plugin_install_#{k}"
    notifies :restart, "service[elasticsearch]"
  end

  if v[:post_install_curl]

    delayed_exec "install elasticsearch plugin #{k} post curl" do
      block do
        check_file = "#{node.elasticsearch.directory}/.plugin_#{k}_post_curl"
        if !File.exists?(check_file) || File.read(check_file) != '1'
          Chef::Log.info("Sending #{v[:post_install_curl][:method]} request to elasticsearch")
          req = eval('Net::HTTP::' + v[:post_install_curl][:method]).new(v[:post_install_curl][:path], {'Content-Type' => 'application/json'})
          req.body = JSON.dump(v[:post_install_curl][:json_content])
          counter = 0
          while true do
            begin
              resp = Net::HTTP.new('localhost', node.elasticsearch.http_port).start {|http| http.request(req) }
              break
            rescue
              counter += 1
              raise "Too many try for post install #{k}" if counter > 10
              sleep 2
            end
          end
          raise "Wrong return for post install #{k} : #{resp.code}" unless v[:post_install_curl][:return_codes].include?(resp.code.to_i)
          Chef::Log.info("Request result ok")
          File.open(check_file, 'w') {|io| io.write(1)}
        end
      end
    end

  end

end
