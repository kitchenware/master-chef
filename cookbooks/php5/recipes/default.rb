
package "php5"

if node.php5[:modules]

  node.php5.modules.each do |m|

    php5_module m

  end

end

if node.php5[:pear] || node.php5[:pear_modules] || node.php5[:pear_channels]

    package "php-pear"

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
