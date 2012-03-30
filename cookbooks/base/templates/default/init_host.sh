#!/bin/sh -e

DIRNAME=`dirname $0`
cd $DIRNAME

SYNTAX="$0 hostname ip netmask gateway"

check_not_empty() {
  if [ "$1" = "" ]; then
    echo $SYNTAX
    exit 13
  fi
}

HOSTNAME=$1
check_not_empty $HOSTNAME
shift

IP=$1
check_not_empty $IP
shift

NETMASK=$1
check_not_empty $NETMASK
shift

GATEWAY=$1
check_not_empty $GATEWAY
shift

echo "$HOSTNAME" > /etc/hostname
hostname $HOSTNAME
./regen_ssh.sh

cat <<EOF | sed -e "s/##IP##/$IP/g" | sed -e "s/##NETMASK##/$NETMASK/g" | sed -e "s/##GATEWAY##/$GATEWAY/g" > /etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
#iface eth0 inet dhcp 
iface eth0 inet static
  address ##IP##
  netmask ##NETMASK##
  gateway ##GATEWAY##

EOF

echo "Done."