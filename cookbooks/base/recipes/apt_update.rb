
if node['platform'] == "ubuntu" || node['platform'] == "debian"

  execute "apt-get update"
  
end