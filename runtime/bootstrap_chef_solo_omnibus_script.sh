#!/bin/sh -e

server=$1

if [ "$user" = "" ]; then
  user="chef"
fi

if [ "$PROXY" != "" ]; then
  PROXY="http_proxy=$PROXY https_proxy=$PROXY"
fi

if ! ssh $user@$server test -d /opt/chef ; then
  echo '/opt/chef does not exists.'
  exit 1
fi

current_folder=$(dirname $0)

ssh $user@$server sudo mkdir -p /opt/master-chef/etc

scp ${current_folder}/../cookbooks/master_chef/templates/default/solo.rb $user@$server:/tmp/solo.rb
scp ${current_folder}/default.json $user@$server:/tmp/local.json
ssh $user@$server sudo mv /tmp/solo.rb /tmp/local.json /opt/master-chef/etc/

ssh $user@$server GIT_CACHE_DIRECTORY=/opt/master-chef/var/git_repos $PROXY MASTER_CHEF_CONFIG=/opt/master-chef/etc/local.json sudo -E /opt/chef/bin/chef-solo -c /opt/master-chef/etc/solo.rb
