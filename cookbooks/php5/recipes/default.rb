
package "php5"

node.php5[:modules].each do |m|
  package "php5-#{m}"
end