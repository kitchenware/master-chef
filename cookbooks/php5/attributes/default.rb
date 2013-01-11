default[:php5][:php_ini] = {
  :max_execution_time => 30,
  :max_input_time => 60,
  :memory_limit => "128M",
  :display_errors => false,
  :post_max_size => "8M",
  :max_file_uploads => 20,
  :upload_max_filesize => "2M",
  :magic_quotes_gpc => false,
  :magic_quotes_runtime => false,
  :default_charset => "iso-8859-1",
  :default_mimetype => "text/html",
  :date_timezone => "Europe/Paris",
  :safe_mode => false,
  :safe_mode_include_dir => [],
  :safe_mode_exec_dir => [],
  :safe_mode_gid => false,
  :open_basedir => [],
  :error_log => "/var/log/php/error.log",
  :user_ini => "",
  :expose_php => false,
  :register_globals => false,
  :disable_functions => {
    "ini_set" => false,
    "pcntl_alarm" => true,
    "pcntl_fork" => true,
    "pcntl_waitpid" => true,
    "pcntl_wait" => true,
    "pcntl_wifexited" => true,
    "pcntl_wifstopped" => true,
    "pcntl_wifsignaled" => true,
    "pcntl_wexitstatus" => true,
    "pcntl_wtermsig" => true,
    "pcntl_wstopsig" => true,
    "pcntl_signal" => true,
    "pcntl_signal_dispatch" => true,
    "pcntl_get_last_error" => true,
    "pcntl_strerror" => true,
    "pcntl_sigprocmask" => true,
    "pcntl_sigwaitinfo" => true,
    "pcntl_sigtimedwait" => true,
    "pcntl_exec" => true,
    "pcntl_getpriority" => true,
    "pcntl_setpriority" => true,
  }
}

default[:php5][:cli_php_ini] = node.php5.php_ini.to_hash.merge({
  :memory_limit => "-1",
})


default[:php5][:apc] = {
  :shm_size => 30,
  :slam_defense => 0,
}

default[:php5][:apc_vhost] = {
  :listen => "127.0.0.1:2323",
  :document_root => "/opt/apc",
}

