
if node[:unicorn_apps]

  node.unicorn_apps.each do |k, v|

    unicorn_app k do
      unicorn_cmd "unicorn"
      user v[:user]
      app_directory v[:app_directory] if v[:app_directory]
      location v[:location] if v[:location]
      configure_nginx v[:configure_nginx] if v[:configure_nginx]
    end

  end

end