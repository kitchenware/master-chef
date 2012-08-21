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
default[:collectd][:interval] = 10