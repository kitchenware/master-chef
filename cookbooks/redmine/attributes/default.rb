default[:redmine] = {
	:user => "redmine",
	:directory => "/opt/redmine",
	:version => "2.6.6",
	:git_url => "git://github.com/edavis10/redmine.git",
	:location => "/redmine",
	:configure_nginx => true,
	:google_apps => false,
	:google_apps_plugin_git => "https://github.com/twinslash/redmine_omniauth_google.git",
	:database => {
  	:host => "localhost",
  	:username => "redmine",
  	:database => "redmine",
  }
}
