
define :sudo_sudoers_file, {
  :content => nil,
} do

  sudo_sudoers_file_params = params

  raise "Please specify content with sudo_sudoers_file" unless sudo_sudoers_file_params[:content]

  directory "/etc/sudoers.d" do
    owner "root"
    mode 0755
  end

  execute "add includedir /etc/sudoers.d in sudoers" do
    command "echo '#includedir /etc/sudoers.d' >> /etc/sudoers"
    not_if "cat /etc/sudoers | grep '#includedir /etc/sudoers.d'"
  end

  template "/etc/sudoers.d/#{sudo_sudoers_file_params[:name]}" do
    cookbook "sudo"
    source "sudoers.erb"
    owner "root"
    mode 0440
    variables :content => sudo_sudoers_file_params[:content]
  end

end