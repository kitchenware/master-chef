
capistrano_app node.kibana3.directory do
  user "root"
end

git_clone "#{node.kibana3.directory}/current" do
  user "root"
  reference node.kibana3.version
  repository node.kibana3.git
end
