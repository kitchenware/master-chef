#!/bin/bash

TARGET=$1

WARP_FILE="ruby_`lsb_release -cs`_`arch`_ree-1.8.7-2012.01_rbenv_chef.warp"
WARP_ROOT="http://warp-repo.s3-eu-west-1.amazonaws.com"
SUDO=''

if [ "$NO_SUDO" = "" ]; then
  SUDO='sudo'
fi

cat <<-EOF | ssh $SSH_OPTS $TARGET $SUDO bash

apt-get -y update
apt-get -y install git-core curl bzip2 sudo file lsb-release
apt-get clean

groupadd sudo

useradd -m -g sudo -s /bin/bash chef

$SUDO echo "chef   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

$SUDO mkdir -p /home/chef/.ssh/
$SUDO cp \$HOME/.ssh/authorized_keys /home/chef/.ssh/authorized_keys
$SUDO chown -R chef /home/chef/.ssh

EOF

HOST=`echo $TARGET | cut -d'@' -f2`
echo "Connecting to chef@$HOST"
cat <<-EOF | ssh chef@$HOST

[ -f $WARP_FILE ] || wget "$WARP_ROOT/$WARP_FILE"
sh $WARP_FILE

EOF