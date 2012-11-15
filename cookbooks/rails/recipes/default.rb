
if node[:rails_app]

  node.rails_app.each do |k, v|

    include_recipe "mysql::server" if v[:mysql_database]

    rails_app k do
      user v[:user]
      app_directory v[:app_directory] if v[:app_directory]
      mysql_database v[:mysql_database] if v[:mysql_database]
      mysql_adapter v[:mysql_adapter] if v[:mysql_adapter]
    end

    if v[:unicorn]

      unicorn_rails_app k do
        location v[:location] if v[:unicorn][:location]
        code_for_initd v[:code_for_initd] if v[:unicorn][:code_for_initd]
        configure_nginx v[:configure_nginx] if v[:unicorn][:configure_nginx]
      end

    end

  end

end