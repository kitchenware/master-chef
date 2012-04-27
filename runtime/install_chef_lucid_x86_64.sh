#!/bin/bash

TARGET=$1

KEY=`cat $HOME/.ssh/id_rsa.pub`
WARP_FILE="ruby_lucid_x86_64_ree-1.8.7-2012.01_rbenv_chef.warp"
WARP_ROOT="https://warp-repo.s3-eu-west-1.amazonaws.com"

cat <<-EOF | ssh $SSH_OPTS $TARGET sudo bash

mkdir -p \$HOME/.ssh

echo $KEY > \$HOME/.ssh/authorized_keys

useradd -m -g sudo -s /bin/bash chef

apt-get -y update
apt-get -y install git-core curl 
apt-get clean


sudo echo "chef   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

sudo mkdir -p /home/chef/.ssh/
sudo cp \$HOME/.ssh/authorized_keys /home/chef/.ssh/authorized_keys
sudo chown -R chef /home/chef/.ssh

EOF

HOST=`echo $TARGET | cut -d'@' -f2` 
cat <<-EOF | ssh chef@$HOST

[ -f $WARP_FILE ] || wget "$WARP_ROOT/$WARP_FILE"
sh $WARP_FILE

EOF