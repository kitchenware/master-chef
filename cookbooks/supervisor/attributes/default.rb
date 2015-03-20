
default[:supervisor][:log_dir] = "/var/log/supervisor"
default[:supervisor][:service_name] = "supervisord"
default[:supervisor][:restart_delay_by_job] = 4

default[:supervisor][:before_start_code] = {}