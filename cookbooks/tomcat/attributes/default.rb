default[:tomcat] = {
	:home => "/opt/tomcat",
	:version => "6.0.35",
	:instances_base => "/opt/tomcat/instances",
	:log_dir => "/var/log/tomcat",
	:user => "tomcat",
}

default[:tomcat][:instances] = {}
