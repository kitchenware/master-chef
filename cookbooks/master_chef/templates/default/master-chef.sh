#!/bin/bash

if [ "$MASTER_CHEF_CONFIG" = "" ]; then
  MASTER_CHEF_CONFIG="<%= @config_file %>"
fi

STATUS_FILE="/opt/chef/var/last/result"
LOG_FILE="/opt/chef/var/last/log"
REPOS_STATUS_FILE="/opt/chef/var/last/repos.json"
FILE_OWNER="<%= @user %>"

log() {
  echo $1 | tee $STATUS_FILE
  chown $FILE_OWNER $STATUS_FILE
}

log "Starting chef using omnibus at `date`"

(
  REPOS_STATUS_FILE=$REPOS_STATUS_FILE MASTER_CHEF_CONFIG=$MASTER_CHEF_CONFIG sudo -E /opt/chef/bin/chef-solo -c /opt/chef/etc/solo.rb
  if [ "$?" = 0 ]; then
    log "Chef run OK at `date`"
  else
    log "Chef run FAILED at `date`"
  fi
) | tee $LOG_FILE

chown $FILE_OWNER $LOG_FILE
cat $STATUS_FILE | grep OK > /dev/null
