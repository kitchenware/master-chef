
default[:postgresql] = {
  :root_account => 'root',
  :user => 'postgres',
  :version => '9.1',
  :user_filters => ['127.0.0.1/32', '::1/128'],
  :listen_addresses => '127.0.0.1',
  :databases => {},
  :service_name => 'postgresql',
  :contrib => false,
  :extended_pg_hba_lines => {},
  :no_databases => false,
}