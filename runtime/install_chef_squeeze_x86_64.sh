#!/bin/bash

source `dirname $0`/install_chef_common.sh

if [ "$INSTALL_USER" = "" ]; then
  INSTALL_USER="admin"
fi

apt_based_init_script "git-core curl bzip2 sudo file lsb-release"

WARP_FILE="ruby_squeeze_x86_64_ree-1.8.7-2012.01_rbenv_chef.warp"
OMNIBUS_DEB="http://opscode-omnibus-packages.s3.amazonaws.com/debian/6/x86_64/chef_11.4.4-2.debian.6.0.5_amd64.deb"

chef_install
