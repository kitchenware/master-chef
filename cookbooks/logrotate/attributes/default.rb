
default[:logrotate][:files] = {}

default[:logrotate][:default_config] = {
	:rotate => 52,
	:frequency => 'daily',
	:user => 'root',
	:group => 'root',
	:mode => '644',
  :delaycompress => 'yes'
}

default[:logrotate][:disable_conf_purge] = false

default[:logrotate][:auto_deploy] = true