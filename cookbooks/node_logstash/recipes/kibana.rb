
ruby_user node.kibana.user do
    install_rbenv true
end

capistrano_app node.kibana.directory do
  user node.kibana.user
end

unicorn_app 'kibana' do
  user node.kibana.user
  location node.kibana.location
  app_directory node.kibana.directory
end

git_clone "#{node.kibana.directory}/current" do
  user node.kibana.user
  reference node.kibana.version
  repository node.kibana.git
  notifies :restart, resources(:service => "kibana")
end

deployed_files = %w{Gemfile Gemfile.lock .rbenv-version .rbenv-gemsets}

directory "#{node.kibana.directory}/shared/files" do
  owner node.kibana.user
end

deployed_files.each do |f|
  template "#{node.kibana.directory}/shared/files/#{f}" do
    owner node.kibana.user
    source "kibana/#{f}"
  end
end

cp_command = deployed_files.map{|f| "cp #{node.kibana.directory}/shared/files/#{f} #{node.kibana.directory}/current/#{f}"}.join(' && ')

ruby_rbenv_command "initialize kibana" do
  user node.kibana.user
  directory "#{node.kibana.directory}/current"
  code "rm -f .warped && #{cp_command} && rbenv warp install"
  version node.kibana.version
end
