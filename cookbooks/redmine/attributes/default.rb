default[:redmine] = {
	:user => "redmine",
	:directory => "/home/redmine/redmine",
	:version => "2.3.3",
	:git_url => "git://github.com/edavis10/redmine.git",
	:location => "/redmine",
	:configure_nginx => true,
	:google_apps => false,
	:google_apps_plugin_git => "https://github.com/mikrob/redmine_google_apps.git",
	:database => {
  	:host => "localhost",
  	:username => "redmine",
  	:database => "redmine",
  }
}
