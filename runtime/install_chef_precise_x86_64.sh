#!/bin/bash

source `dirname $0`/install_chef_common.sh

if [ "$INSTALL_USER" = "" ]; then
  INSTALL_USER="ubuntu"
fi

read -r -d '' INIT_SCRIPT <<EOF

mkdir -p \$HOME/.ssh &&

echo $KEY > \$HOME/.ssh/authorized_keys &&

useradd -m -g sudo -s /bin/bash chef &&

$PROXY apt-get -y update &&
$PROXY apt-get -y install git-core curl bzip2 &&
$PROXY apt-get clean &&

echo "chef   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers &&

mkdir -p /home/chef/.ssh/ &&
cp \$HOME/.ssh/authorized_keys /home/chef/.ssh/authorized_keys &&
chown -R chef /home/chef/.ssh

EOF

WARP_FILE="ruby_precise_x86_64_ree-1.8.7-2012.01_rbenv_chef.warp"
OMNIBUS_DEB="http://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/11.04/x86_64/chef_11.4.4-2.ubuntu.11.04_amd64.deb"

chef_install