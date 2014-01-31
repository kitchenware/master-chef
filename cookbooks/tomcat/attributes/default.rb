default[:tomcat] = {
	:home => "/opt/tomcat",
	:version => "6.0.35",
	:instances_base => "/opt/tomcat/instances",
	:log_dir => "/var/log/tomcat",
	:user => "tomcat",
}

default[:tomcat][:catalina_home] = "/opt/tomcat/apache-tomcat-#{default[:tomcat][:version]}"
default[:tomcat][:warp_file] = "apache-tomcat-#{default[:tomcat][:version]}_`lsb_release -cs`_`arch`.warp"

default[:tomcat][:instances] = {}
