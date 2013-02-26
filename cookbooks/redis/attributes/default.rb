default[:redis] = {
  :bind_address => '127.0.0.1',
  :port => 6379,
  :timeout => 300,
  :log_level => 'notice',
  :log_file => '/var/log/redis/redis-server.log',
  :databases => 16,
  :save => ["900 1", "300 10", "60 10000"],
  :directory => '/var/lib/redis',
  :maxclients => 128,
  :maxmemory => nil,
  :appendonly => 'no',
  :appendfsync => 'everysec',
}