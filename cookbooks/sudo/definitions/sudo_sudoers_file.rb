
define :sudo_sudoers_file, {
  :content => nil,
} do

  sudo_sudoers_file_params = params

  raise "Please specify content with sudo_sudoers_file" unless sudo_sudoers_file_params[:content]

  template "/etc/sudoers.d/#{sudo_sudoers_file_params[:name]}" do
    cookbook "sudo"
    source "sudoers.erb"
    owner "root"
    mode 0440
    variables :content => sudo_sudoers_file_params[:content]
  end

end