default[:redmine] = {
	:user => "redmine",
	:directory => "/opt/redmine",
	:version => "3.0.4",
	:git_url => "git://github.com/edavis10/redmine.git",
	:location => "/redmine",
	:configure_nginx => true,
	:google_apps => false,
	:google_apps_plugin_git => "https://github.com/zumbrunnen/redmine_omniauth_google.git",
  :google_apps_plugin_branch => "zumbrunnen-redmine-3x-fix",
	:database => {
  	:host => "localhost",
  	:username => "redmine",
  	:database => "redmine",
  }
}
