#!/bin/sh

if [ "$MASTER_CHEF_CONFIG" = "" ]; then
  MASTER_CHEF_CONFIG="<%= @config_file %>"
fi

HOME="<%= @user_home %>"
if [ "$LOG_PREFIX" = "" ]; then
  LOG_PREFIX="<%= @log_prefix %>"
fi
STATUS_FILE="${LOG_PREFIX}_run"
LOG_FILE="${LOG_PREFIX}_log"
REPOS_STATUS_FILE="${LOG_PREFIX}_repos.json"
FILE_OWNER="<%= @user %>"

log() {
  echo $1 | tee $STATUS_FILE
  chown $FILE_OWNER $STATUS_FILE
}

log "Starting chef at `date`"

(
  REPOS_STATUS_FILE=$REPOS_STATUS_FILE MASTER_CHEF_CONFIG=$MASTER_CHEF_CONFIG /etc/chef/rbenv_sudo_chef.sh -c /etc/chef/solo.rb
  if [ "$?" = 0 ]; then
    log "Chef run OK at `date`"
  else
    log "Chef run FAILED at `date`"
  fi
) | tee $LOG_FILE

chown $FILE_OWNER $LOG_FILE
cat $STATUS_FILE | grep ok > /dev/null
