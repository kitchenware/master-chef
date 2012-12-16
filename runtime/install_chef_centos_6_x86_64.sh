#!/bin/bash

TARGET=$1

KEY=`cat $HOME/.ssh/id_rsa.pub`
WARP_FILE="ruby_centos_6_x86_64_ree-1.8.7-2012.02_rbenv_chef.warp"
WARP_ROOT="http://warp-repo.s3-eu-west-1.amazonaws.com"

cat <<-EOF | ssh $SSH_OPTS $TARGET bash

mkdir -p \$HOME/.ssh

echo $KEY > \$HOME/.ssh/authorized_keys

yum install -y git sudo man wget
yum clean

useradd -m -s /bin/bash chef

echo "chef   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

sed -i -r -e 's/^(Defaults\s+requiretty)/#\1/' /etc/sudoers

mkdir -p /home/chef/.ssh/
cp \$HOME/.ssh/authorized_keys /home/chef/.ssh/authorized_keys
chown -R chef /home/chef/.ssh

EOF

HOST=`echo $TARGET | cut -d'@' -f2`
cat <<-EOF | ssh chef@$HOST

[ -f $WARP_FILE ] || wget "$WARP_ROOT/$WARP_FILE"
sh $WARP_FILE

EOF