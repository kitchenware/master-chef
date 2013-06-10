require 'rubygems'
require "bundler/setup"

task :foodcritic do
  # Delete tags FC011, FC014, FC015, FC019, FC023, FC041
  tags_list = "FC001,FC002,FC003,FC004,FC005,FC006,FC007,FC008,FC009,FC010,FC012,FC013,FC016,FC017,FC018,FC020,FC021,FC022,FC024,FC025,FC026,FC027,FC028,FC029,FC030,FC031,FC032,FC033,FC034,FC035,FC036,FC037,FC038,FC039,FC042,FC043,FC044,FC045"
  sh "foodcritic cookbooks -t #{tags_list} -f #{tags_list}"
end

task :default => [:foodcritic]