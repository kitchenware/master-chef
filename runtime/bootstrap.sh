#!/bin/bash

WARP_ROOT="http://warp-repo.s3-eu-west-1.amazonaws.com"

if [ "$PROXY" != "" ]; then
  PROXY="http_proxy=$PROXY https_proxy=$PROXY"
fi

if [ "$MASTER_CHEF_URL" = "" ]; then
  # non standard url. rawgithub.com support http, raw.github.com does not
  MASTER_CHEF_URL="http://rawgithub.com/octo-technology/master-chef"
fi

if [ "$MASTER_CHEF_HASH_CODE" = "" ]; then
  MASTER_CHEF_HASH_CODE="master"
else
  MASTER_CHEF_FIRST_RUN="GIT_TAG_OVERRIDE=\"http://github.com/octo-technology/master-chef.git=$MASTER_CHEF_HASH_CODE\""
fi

print() {
  echo "/---------------------------------------------------------"
  echo "| $1"
  echo "\\---------------------------------------------------------"
}

print "Welcome into Master-Chef bootstraper !"

SUDO="sudo"
if [ "$USER" = "root" ]; then
  SUDO=""
else
  if ! $SUDO /bin/sh -c 'uname' > /dev/null; then
    echo "Cannot use sudo !"
    exit 1
  fi
fi

exec_command() {
  cmd="$*"
  sh -c "$cmd"
  if [ $? != 0 ]; then
    echo "Exection failed : $cmd"
    exit 2
  fi
}

exec_command_chef() {
  cmd="$*"
  sh -c "$SUDO sudo -H -u chef /bin/sh -c \"cd /home/chef && $cmd\""
  if [ $? != 0 ]; then
    echo "Exection failed for chef : $cmd"
    exit 2
  fi
}

install_master_chef_file() {
  file=$1
  target=$2
  url="$MASTER_CHEF_URL/$MASTER_CHEF_HASH_CODE/$file"
  echo "Downloading $url to $target"
  exec_command "$SUDO $PROXY curl -f -s -L $url -o $target"
}

install_master_chef_shell_file() {
  install_master_chef_file $1 $2
  exec_command "$SUDO chmod +x $2"
}

while ps axu | grep cloud-init | grep -v grep; do
  echo "Wait end of cloud-init"
  sleep 2
done

if which apt-get > /dev/null; then

  print "Debian based distribution detected"

  exec_command "$SUDO apt-get update"

  if ! which lsb_release > /dev/null; then
    exec_command "$SUDO apt-get install -y lsb-release"
  fi

  distro=`lsb_release -cs`

  print "Detected distro : $distro"

  case $distro in
    squeeze)
      exec_command "$SUDO apt-get install -y git-core curl bzip2 sudo file libreadline5"
      WARP_FILE="ruby_squeeze_x86_64_ree-1.8.7-2012.01_rbenv_chef.warp"
      OMNIBUS_DEB="http://opscode-omnibus-packages.s3.amazonaws.com/debian/6/x86_64/chef_11.4.4-2.debian.6.0.5_amd64.deb"
      ;;
    wheezy)
      exec_command "$SUDO apt-get install -y git-core curl bzip2 sudo file"
      WARP_FILE="ruby_wheezy_x86_64_ree-1.8.7-2012.01_rbenv_chef.warp"
      ;;
    lucid)
      exec_command "$SUDO apt-get install -y git-core curl bzip2"
      WARP_FILE="ruby_lucid_x86_64_ree-1.8.7-2012.01_rbenv_chef.warp"
      OMNIBUS_DEB="http://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/10.04/x86_64/chef_11.4.4-2.ubuntu.10.04_amd64.deb"
      ;;
    precise)
      exec_command "$SUDO apt-get install -y git-core curl bzip2"
      WARP_FILE="ruby_precise_x86_64_ree-1.8.7-2012.01_rbenv_chef.warp"
      OMNIBUS_DEB="http://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/11.04/x86_64/chef_11.4.4-2.ubuntu.11.04_amd64.deb"
      ;;
    *)
      echo "Unknown distro"
      exit 78
  esac

  exec_command "cat /etc/passwd | grep ^chef > /dev/null || $SUDO useradd -m -g sudo -s /bin/bash chef"
  exec_command "$SUDO cat /etc/sudoers | grep ^chef > /dev/null || $SUDO /bin/sh -c 'echo \"chef   ALL=(ALL) NOPASSWD:ALL\" >> /etc/sudoers'"
  exec_command "$SUDO mkdir -p /home/chef/.ssh/"

  if [ "$USER" != "chef" ]; then
    KEYS="$HOME/.ssh/authorized_keys"
    if [ -f $KEYS ]; then
      print "Installing credentials to chef account from $KEYS"
      exec_command "$SUDO cp $KEYS /home/chef/.ssh/authorized_keys"
    else
      echo "File not found $KEYS"
    fi
  fi

  exec_command "$SUDO chown -R chef /home/chef/.ssh"

fi

if [ "$distro" = "" ]; then
  echo "Unknown distro"
  exit 78
fi

if [ "$OMNIBUS" = "" ]; then

  print "Installing chef from warp"

  exec_command_chef "[ -f $WARP_FILE ] || $PROXY curl -f -s -L \"$WARP_ROOT/$WARP_FILE\" -o $WARP_FILE"
  exec_command_chef "$PROXY sh $WARP_FILE"

  exec_command "$SUDO mkdir -p /etc/chef"
  install_master_chef_file "cookbooks/master_chef/templates/default/solo.rb" "/etc/chef/solo.rb"
  install_master_chef_shell_file "cookbooks/master_chef/templates/default/rbenv_sudo_chef.sh" "/etc/chef/rbenv_sudo_chef.sh"
  install_master_chef_file "runtime/local.json" "/etc/chef/local.json"

  print "Bootstraping master-chef"

  exec_command_chef "GIT_CACHE_DIRECTORY=/var/chef/cache/git_repos $PROXY $MASTER_CHEF_FIRST_RUN MASTER_CHEF_CONFIG=/etc/chef/local.json /etc/chef/rbenv_sudo_chef.sh -c /etc/chef/solo.rb"

else

  print "Installing chef from Omnibus"

  if [ "$OMNIBUS_DEB" = "" ]; then
    echo "Omnibus url not set for this distro : $distro"
    exit 42
  fi

  exec_command_chef "[ -f $OMNIBUS_DEB ] || $PROXY curl -f -s -L \"$OMNIBUS_DEB\" -o `basename $OMNIBUS_DEB`"
  exec_command_chef "$SUDO dpkg -i `basename $OMNIBUS_DEB`"

  exec_command "$SUDO mkdir -p /opt/master-chef/etc"
  install_master_chef_file "cookbooks/master_chef/templates/default/solo.rb" "/opt/master-chef/etc/solo.rb"
  install_master_chef_file "runtime/local.json" "/opt/master-chef/etc/local.json"

  print "Bootstraping master-chef"

  exec_command_chef "GIT_CACHE_DIRECTORY=/opt/master-chef/var/git_repos $PROXY $MASTER_CHEF_FIRST_RUN MASTER_CHEF_CONFIG=/opt/master-chef/etc/local.json sudo -E /opt/chef/bin/chef-solo -c /opt/master-chef/etc/solo.rb"

fi

print "Master-chef Ready !!!!!!!"