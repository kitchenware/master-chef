
service "procps" do
  supports :status => true, :reload => true, :restart => true
  action [ :enable, :start ]
end
