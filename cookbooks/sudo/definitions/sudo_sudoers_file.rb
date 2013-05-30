
define :sudo_sudoers_file, {
  :content => nil,
} do

  sudo_sudoers_file_params = params

  raise "Please specify content with sudo_sudoers_file" unless sudo_sudoers_file_params[:content]

  file "/etc/sudoers.d/#{sudo_sudoers_file_params[:name]}" do
    owner "root"
    mode '0440'
    content sudo_sudoers_file_params[:content]
  end

end