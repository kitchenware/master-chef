
package "php5"

if node.php5[:modules]

  node.php5.modules.each do |m|

    php5_module m

  end

end