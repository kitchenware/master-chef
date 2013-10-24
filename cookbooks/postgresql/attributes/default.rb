
default[:postgresql] = {
  :root_account => 'root',
  :user => 'postgres',
  :version => '9.1',
  :user_filter => '127.0.0.1/32',
  :listen_addresses => '127.0.0.1',
  :databases => {},
  :service_name => 'postgresql',
}