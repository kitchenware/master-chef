#!/bin/bash

TARGET=$1
SSH_KEY=$2
SYNTAX="$0 target [ssh_public_key_file]"

if [ "$TARGET" = "" ]; then
  echo $SYNTAX
  exit 1
fi

if [ "$SSH_KEY" = "" ]; then
  SSH_KEY="$HOME/.ssh/id_rsa.pub"
fi

if [ ! -f "$SSH_KEY" ]; then
  echo "SSH key not found : $SSH_KEY"
  exit 1
fi

MAIN_KEY="`dirname $0`/../tests/ssh/id_rsa"
chmod 0600 $MAIN_KEY

ssh -o StrictHostKeyChecking=no -i $MAIN_KEY chef@$TARGET uname > /dev/null

if [ "$?" != 0 ]; then
  echo "Unable to connect to $TARGET"
  exit 1
fi

cat $SSH_KEY | ssh chef@$TARGET 'cat > $HOME/.ssh/authorized_keys'

if [ "$?" != 0 ]; then
  echo "Error while uploading your key to $TARGET"
  exit 1
fi

ssh chef@$TARGET "sudo rm -f /root/.ssh/authorized_keys && sudo ls /home | grep -v chef | perl -pe 's/(.*)/\/home\/\$1\/.ssh\/authorized_keys/' | xargs sudo rm -f"

if [ "$?" != 0 ]; then
  echo "Error while resetings keys on $TARGET"
  exit 1
fi

echo "All ssh keys has been removed on $TARGET."
echo "The only one in place is your ($SSH_KEY) for chef account."