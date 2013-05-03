#!/bin/sh -e

/opt/chef/bin/master-chef.impl.sh

sudo rsync /opt/chef/bin/master-chef.impl.last.sh /opt/chef/bin/master-chef.impl.sh
