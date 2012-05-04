
template "/var/www/phpinfo.php" do
  owner "www-data"
  source "phpinfo.php.erb"
end