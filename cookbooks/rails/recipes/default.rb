
if node[:rails_app]

  node.rails_app.each do |k, v|
    
    unicorn_rails_app k do
      user v[:user]
      app_directory v[:app_directory] if v[:app_directory]
      location v[:location] if v[:location]
      mysql_database v[:mysql_database] if v[:mysql_database]
      mysql_adapter v[:mysql_adapter] if v[:mysql_adapter]
      code_for_initd v[:code_for_initd] if v[:code_for_initd]
      configure_nginx v[:configure_nginx] if v[:configure_nginx]
    end
  
  end

end