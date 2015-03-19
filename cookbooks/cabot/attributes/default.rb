default[:cabot][:root] = "/opt/cabot"

default[:cabot][:git] = "https://github.com/bonniejools/cabot.git"
default[:cabot][:version] = "14a6bcc357cd583d95b49e4fa04821dd34897582"

default[:cabot][:user] = "cabot"

default[:cabot][:port] = 5000

default[:cabot][:extra_config] = {
  :admin_email => "you@example.com",
  :cabot_from_email => "noreply@cabot.com",
  :google_calendar_url => "http://www.google.com/calendar/ical/example.ics",
  :graphite_server => "http://graphite.example.com/",
  :graphite_user => "username",
  :graphite_password => "password",
  :graphite_from => "-10minute",
  :hipchat_room => "48052",
  :hipchat_api_key => "your_hipchat_api_key",
  :jenkins_api => "https://jenkins.example.com/",
  :jenkins_user => "username",
  :jenkins_password => "password",
  :smtp_server => "smtp.example.com",
  :smtp_user => "user",
  :smtp_password => "password",
  :smtp_port => 123,
  :cabot_host => "http://cabot.example.com",
  :scheme => "http",
}

default[:cabot][:nginx][:cabot] = {
  :listen => '0.0.0.0:80',
  :cabot_port => 5000,
}