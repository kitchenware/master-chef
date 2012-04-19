#!/bin/sh

HOME="<%= @user_home %>"
LOG_FILE="<%= @status_file %>"
LOG_FILE_CHEF="<%= @log_file %>"
LOG_FILE_OWNER="<%= @user %>"

log() {
  echo $1 | tee $LOG_FILE
  chown $LOG_FILE_OWNER $LOG_FILE
}

log "Starting chef at `date`"

(
  MASTER_CHEF_CONFIG="<%= @config_file %>" /etc/chef/rbenv_sudo_chef.sh -c /etc/chef/solo.rb
  if [ "$?" = 0 ]; then
    log "Chef run ok at `date`"
  else
    log "Chef run FAILED at `date`"
  fi
) | tee $LOG_FILE_CHEF
chown $LOG_FILE_OWNER $LOG_FILE_CHEF

cat $LOG_FILE | grep ok > /dev/null