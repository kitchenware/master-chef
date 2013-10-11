
if node.lsb.codename == "lucid"

  # to be compatible with drush
  add_apt_repository "php5_old_stable" do
    url "http://ppa.launchpad.net/ondrej/php5-oldstable/ubuntu"
    key "E5267A6C"
    key_server "keyserver.ubuntu.com"
  end

end

package "php5-common"

if node.php5[:modules]

  node.php5.modules.each do |m|
    php5_module m
  end

end

if node.php5[:pear] || node.php5[:pear_modules] || node.php5[:pear_channels]

  execute "pear upgrade" do
    command "pear upgrade pear"
    action :nothing
  end

  package "php-pear" do
    notifies :run, "execute[pear upgrade]", :immediately
  end

  if ENV['BACKUP_http_proxy']

    execute "pear config-set http_proxy #{ENV['BACKUP_http_proxy']}" do
      not_if "pear config-get http_proxy | grep #{ENV['BACKUP_http_proxy']}"
    end

  end

end

if node.php5[:pear_channels]

  node.php5.pear_channels.each do |m|
    php5_pear_channel m
  end

end

if node.php5[:pear_modules]

  node.php5.pear_modules.each do |m|
    php5_pear_module m
  end

end
