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

KEY=`cat $HOME/.ssh/id_rsa.pub`

WARP_ROOT="http://warp-repo.s3-eu-west-1.amazonaws.com"

chef_install() {

echo "$INIT_SCRIPT" | ssh $SSH_OPTS $INSTALL_USER@$TARGET "cat > /tmp/master_chef_install.sh"

ssh $SSH_OPTS $INSTALL_USER@$TARGET "sudo sh /tmp/master_chef_install.sh"

if [ "$OMNIBUS" = "" ]; then

if [ "$WARP_FILE" = "" ]; then
  echo "Warp file not set for this distro"
  exit 42
fi

cat <<-EOF | ssh $SSH_OPTS $CHEF_USER@$TARGET

[ -f $WARP_FILE ] || $PROXY wget "$WARP_ROOT/$WARP_FILE"
$PROXY sh $WARP_FILE

EOF

else

if [ "$OMNIBUS_DEB" = "" ]; then
  echo "Omnibus url not set for this distro"
  exit 42
fi

cat <<-EOF | ssh $SSH_OPTS $CHEF_USER@$TARGET

[ -f $OMNIBUS_DEB ] || $PROXY wget "$OMNIBUS_DEB"
sudo dpkg -i `basename $OMNIBUS_DEB`

EOF

fi

}