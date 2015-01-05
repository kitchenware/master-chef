default[:collectd][:plugins] = {
  "cpu" => {},
  "df" => {},
  "disk" => {},
  "entropy" => {},
  "interface" => {},
  "irq" => {},
  "memory" => {},
  "processes" => {},
  "swap" => {},
  "users" => {},
  "syslog" => {:config => "LogLevel \"info\""}
}
default[:collectd][:package_name] = "collectd-core"
default[:collectd][:interval] = 10
default[:collectd][:config_directory] = "/etc/collectd/collectd.d"
default[:collectd][:home_directory] = "/opt/collectd"
