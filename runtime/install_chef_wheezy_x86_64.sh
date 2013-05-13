#!/bin/bash

source `dirname $0`/install_chef_common.sh

if [ "$INSTALL_USER" = "" ]; then
  INSTALL_USER="admin"
fi

apt_based_init_script "git-core curl bzip2 sudo file lsb-release"

WARP_FILE="ruby_wheezy_x86_64_ree-1.8.7-2012.01_rbenv_chef.warp"

chef_install
