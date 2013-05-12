#!/bin/sh -e

TARGET=$1

if [ "$TARGET" = "" ]; then
  echo "Please specify target on command line"
  exit 2
fi

if [ "$CHEF_USER" = "" ]; then
  CHEF_USER="chef"
fi

KEY=`cat $HOME/.ssh/id_rsa.pub`

cat <<-EOF | ssh $SSH_OPTS root@$TARGET "cat > /tmp/master_chef_install.sh"

mkdir -p \$HOME/.ssh

echo $KEY > \$HOME/.ssh/authorized_keys

apt-get -y update
apt-get -y install git-core curl bzip2 sudo file lsb-release
apt-get clean

groupadd sudo

useradd -m -g sudo -s /bin/bash $CHEF_USER

sudo echo "$CHEF_USER   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

sudo mkdir -p /home/$CHEF_USER/.ssh/
sudo cp \$HOME/.ssh/authorized_keys /home/$CHEF_USER/.ssh/authorized_keys
sudo chown -R $CHEF_USER /home/$CHEF_USER/.ssh

EOF

ssh $SSH_OPTS root@$TARGET "sh /tmp/master_chef_install.sh"

if [ "$OMNIBUS" = "" ]; then

WARP_FILE="ruby_squeeze_x86_64_ree-1.8.7-2012.01_rbenv_chef.warp"
WARP_ROOT="http://warp-repo.s3-eu-west-1.amazonaws.com"

cat <<-EOF | ssh $SSH_OPTS $CHEF_USER@$TARGET

[ -f $WARP_FILE ] || wget "$WARP_ROOT/$WARP_FILE"
sh $WARP_FILE

EOF

else

OMNIBUS_DEB="https://opscode-omnibus-packages.s3.amazonaws.com/debian/6/x86_64/chef_11.4.4-2.debian.6.0.5_amd64.deb"
cat <<-EOF | ssh $SSH_OPTS $CHEF_USER@$TARGET

[ -f $OMNIBUS_DEB ] || wget "$OMNIBUS_DEB"
sudo dpkg -i `basename $OMNIBUS_DEB`

EOF

fi