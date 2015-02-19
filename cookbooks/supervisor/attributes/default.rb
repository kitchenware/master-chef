default[:supervisor][:log_dir] = "/var/log/supervisor"
default[:supervisor][:log_maxbytes] = "10M"
default[:supervisor][:log_maxfiles] = 10
default[:supervisor][:service_name] = "supervisord"
default[:supervisor][:restart_delay_by_job] = 4