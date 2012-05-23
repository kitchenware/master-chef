#!/bin/sh

HOME="<%= @user_home %>"
if [ "$STATUS_FILE" = "" ]; then
  STATUS_FILE="<%= @status_file %>"
fi
if [ "$LOG_FILE_CHEF" = "" ]; then
  LOG_FILE_CHEF="<%= @log_file %>"
fi
FILE_OWNER="<%= @user %>"

log() {
  echo $1 | tee $STATUS_FILE
  chown $FILE_OWNER $STATUS_FILE
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
chown $FILE_OWNER $LOG_FILE_CHEF

cat $STATUS_FILE | grep ok > /dev/null