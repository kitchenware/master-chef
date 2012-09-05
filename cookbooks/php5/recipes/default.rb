
package "php5"

if node.php5[:modules]

  node.php5.modules.each do |m|

    php5_module m

  end

end

if node.php5[:pear] || node.php5[:pear_modules] || node.php5[:pear_channels]

  bash "pear upgrade" do
    code "pear upgrade pear"
    action :nothing
  end

  package "php-pear" do
    notifies :run, "bash[pear upgrade]", :immediately
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
