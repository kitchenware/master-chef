
define :base_ppa, {
  :url => nil
} do
  base_ppa_params = params

  raise "base_ppa command is only available on ubuntu" if node['platform'] != "ubuntu"
  
  raise "Please specify url with base_ppa" unless base_ppa_params[:url]

  package "python-software-properties"

  bash "ppa : #{base_ppa_params[:name]}" do
    code "add-apt-repository #{base_ppa_params[:url]} && apt-get update"
    not_if "ls /etc/apt/sources.list.d | grep #{base_ppa_params[:name]}"
  end

end