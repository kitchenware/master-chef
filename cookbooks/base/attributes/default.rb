default[:warp][:warp_src] = "http://warp-repo.s3-eu-west-1.amazonaws.com"

default[:locales] = {
  :configure => true,
  :list => ["en_US ISO-8859-1", "en_US.UTF-8 UTF-8"],
  :default_locale => "en_US.UTF-8",
}

default[:timezone] = "Etc/GMT"
default[:ntp_servers] = ["0.pool.ntp.org", "1.pool.ntp.org", "2.pool.ntp.org", "3.pool.ntp.org"]
default[:ntp_local_stratum] = 15
default[:bash_users] = ["root"]

default[:ssh] = {
  :allow_ssh_root_login => false,
  :max_startups => "10:30:60",
  :use_dns => false,
  :client_alive_interval => 60,
  :client_alive_count_max => 3,
  :gateway_ports => false,
}

default[:apt] = {
  :configure_proxy_from_env => true,
  :force_dist_upgrade => false,
  :clean_sources_list_d => true,
  :master_chef_add_apt_repo => true,
}

default[:purge_sudoers] = true
