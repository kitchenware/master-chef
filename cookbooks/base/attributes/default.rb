default[:warp][:warp_src] = "https://warp-repo.s3-eu-west-1.amazonaws.com"

default[:locales] = {
  :configure => true,
  :list => ["en_US ISO-8859-1", "en_US.UTF-8 UTF-8"],
  :default_locale => "en_US.UTF-8",
}

default[:timezone] = "Etc/GMT"
default[:ntp_servers] = ["0.pool.ntp.org", "1.pool.ntp.org", "2.pool.ntp.org", "3.pool.ntp.org"]
default[:bash_users] = ["root"]
