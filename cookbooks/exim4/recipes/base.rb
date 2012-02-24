
package "exim4"

service "exim4" do
  supports :status => true, :reload => true, :restart => true
  action [ :enable, :start ]
end
