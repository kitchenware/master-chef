
define :postgresql_database, {
} do
  postgresql_database_params = params

  config = extract_config postgresql_database_params[:name]

  if config[:host] == "localhost"

    unless config[:password]
      config[:password] = local_storage_read("postgresql_password:#{config[:username]}") do
        PasswordGenerator.generate 32
      end
    end

    execute "create user #{config[:username]}" do
      user node.postgresql.user
      command "psql --command \"CREATE USER #{config[:username]} WITH NOCREATEDB NOCREATEUSER NOCREATEROLE PASSWORD '#{config[:password]}';\""
      not_if "sudo -u #{node.postgresql.user} psql --command=\"select usename from pg_catalog.pg_user;\" --tuples-only | grep #{config[:username]}"
    end

    execute "create database #{config[:database]}" do
      user node.postgresql.user
      command "psql --command \"CREATE DATABASE #{config[:database]};\""
      not_if "sudo -u #{node.postgresql.user} psql --command=\"select datname from pg_catalog.pg_database;\" --tuples-only | grep #{config[:database]}"
    end

  end

  if config[:postgresql_wrapper]

    template config[:postgresql_wrapper][:file] do
      cookbook "postgresql"
      source "postgresql.sh.erb"
      variables :config => config
      mode '0700'
      owner config[:postgresql_wrapper][:owner]
      action :nothing
    end

    # directory enclosing wrapper file is often created after, or does not exists (server with db only)
    delayed_exec "create #{config[:postgresql_wrapper][:file]}" do
      after_block_notifies :create, "template[#{config[:postgresql_wrapper][:file]}]"
      block do
        File.exists? File.dirname(config[:postgresql_wrapper][:file])
      end
    end

  end

end