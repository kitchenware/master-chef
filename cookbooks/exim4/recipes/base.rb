
package "exim4"

Chef::Config.exception_handlers << ServiceErrorHandler.new("exim4", "exim")

service "exim4" do
  supports :status => true, :reload => true, :restart => true
  action auto_compute_action
end
