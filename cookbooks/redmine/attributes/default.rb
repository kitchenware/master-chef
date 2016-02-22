default[:redmine] = {
	:user => "redmine",
	:directory => "/opt/redmine",
	:version => "3.0.4",
	:git_url => "git://github.com/edavis10/redmine.git",
	:location => "/redmine",
	:configure_nginx => true,
	:google_apps => false,
	:google_apps_plugin_git => "https://github.com/doctolib/redmine_omniauth_google.git",
  :google_apps_plugin_branch => "master",
	:database => {
  	:host => "localhost",
  	:username => "redmine",
  	:database => "redmine",
  },
  :smtp_domain => 'example.com'
}
