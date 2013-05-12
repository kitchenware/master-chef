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

ssh $SSH_OPTS $CHEF_USER@$TARGET sudo mkdir -p /etc/chef/
current_folder=$(dirname $0)

scp $SSH_OPTS $current_folder/../cookbooks/master_chef/templates/default/solo.rb $CHEF_USER@$TARGET:/tmp/solo.rb
scp $SSH_OPTS $current_folder/../cookbooks/master_chef/templates/default/rbenv_sudo_chef.sh $CHEF_USER@$TARGET:/tmp/rbenv_sudo_chef.sh
ssh $SSH_OPTS $CHEF_USER@$TARGET sudo mv /tmp/solo.rb /etc/chef/solo.rb
ssh $SSH_OPTS $CHEF_USER@$TARGET sudo mv /tmp/rbenv_sudo_chef.sh /etc/chef/rbenv_sudo_chef.sh

scp $SSH_OPTS ${current_folder}/default.json $CHEF_USER@$TARGET:/tmp/default.json
ssh $SSH_OPTS $CHEF_USER@$TARGET sudo mv /tmp/default.json /etc/chef/local.json
ssh $SSH_OPTS $CHEF_USER@$TARGET sudo chmod +x /etc/chef/rbenv_sudo_chef.sh
ssh $SSH_OPTS $CHEF_USER@$TARGET GIT_CACHE_DIRECTORY=/var/chef/cache/git_repos $PROXY MASTER_CHEF_CONFIG=/etc/chef/local.json /etc/chef/rbenv_sudo_chef.sh -c /etc/chef/solo.rb
