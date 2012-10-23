
package "exim4"

service "exim4" do
  supports :status => true, :reload => true, :restart => true
  action auto_compute_action
end

Chef::Config.exception_handlers << ServiceErrorHandler.new("exim4", "exim")