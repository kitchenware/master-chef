default[:cabot][:root] = "/opt/cabot"

default[:cabot][:git] = "https://github.com/doctolib/cabot.git"
default[:cabot][:version] = "0539beda938aebd1a3947c42da1322597be99e26"

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
  :alert_interval => "60", # minutes
  :notification_interval => "60", # minutes
}

default[:cabot][:plugins] = {
  'cabot_alert_hipchat' => '1.6.1',
  'cabot_alert_email' => 'git+https://git@github.com/doctolib/cabot-alert-email.git@22f28d9f290e5e161716cc6691f412330a566a19#egg=cabot_alert_email-1.3.166',
  'cabot_alert_twilio' => '1.1.4',
}

default[:cabot][:nginx][:cabot] = {
  :listen => '0.0.0.0:80',
  :cabot_port => 5000,
}