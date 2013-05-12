#!/bin/sh -e

TARGET=$1

if [ "$TARGET" = "" ]; then
  echo "Please specify target on command line"
  exit 2
fi

if [ "$CHEF_USER" = "" ]; then
  CHEF_USER="chef"
fi

if [ "$PROXY" != "" ]; then
  PROXY="http_proxy=$PROXY https_proxy=$PROXY"
fi
if ! ssh $SSH_OPTS $CHEF_USER@$TARGET test -d /opt/chef ; then
  echo '/opt/chef does not exists.'
  exit 1
fi

current_folder=$(dirname $0)

ssh $SSH_OPTS $CHEF_USER@$TARGET sudo mkdir -p /opt/master-chef/etc

scp $SSH_OPTS ${current_folder}/../cookbooks/master_chef/templates/default/solo.rb $CHEF_USER@$TARGET:/tmp/solo.rb
scp $SSH_OPTS ${current_folder}/default.json $CHEF_USER@$TARGET:/tmp/local.json
ssh $SSH_OPTS $CHEF_USER@$TARGET sudo mv /tmp/solo.rb /tmp/local.json /opt/master-chef/etc/

ssh $SSH_OPTS $CHEF_USER@$TARGET GIT_CACHE_DIRECTORY=/opt/master-chef/var/git_repos $PROXY MASTER_CHEF_CONFIG=/opt/master-chef/etc/local.json sudo -E /opt/chef/bin/chef-solo -c /opt/master-chef/etc/solo.rb
