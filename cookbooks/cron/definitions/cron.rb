
define :cron_file, {
  :content => nil
} do
  cron_file_params = params

  raise "Please specify content with cron_file" unless cron_file_params[:content]

  template "/etc/cron.d/#{cron_file_params[:name]}" do
    cookbook "cron"
    source "cron_file.erb"
    mode 0644
    variables :content => cron_file_params[:content]
  end

end