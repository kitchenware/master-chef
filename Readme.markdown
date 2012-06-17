# How to start

This is a quick start guide to use Master-Chef with ec2 instances (only on eu-west-1).

## Create instance from AMI

There is 3 AMI pre-configured with master-chef
* [Debian 6 squeeze](https://console.aws.amazon.com/ec2/home?region=eu-west-1#launchAmi=ami-d1cef5a5)
* [Ubuntu 10 lucid](https://console.aws.amazon.com/ec2/home?region=eu-west-1#launchAmi=ami-2bcff45f)
* [Ubuntu 12 precise](https://console.aws.amazon.com/ec2/home?region=eu-west-1#launchAmi=ami-e36d5797)

You can click on link above to create instance.

## Setup instance with your own SSH key

Clone master chef :

    git clone git://github.com/octo-technology/master-chef.git

Upload your public key :

    runtime/upload_ssh_keys_from_test_instance.sh ip_of_created_instance

You are now the only one which can use it, you can connect using the `chef` account

    ssh chef@ip_of_created_instance

Note : you can also use the AWS key pair, but it's do not setup your key into the `chef` account.

## Enjoy master-chef

SSH the instance

    ssh chef@ip_of_created_instance

Run master-chef

    /etc/chef/update.sh

How to configure it ? All the master-chef is in the file `/etc/chef/local.json`. Re-run `/etc/chef/update.sh` after each `local.json` modification.

You can find lot of examples [here](https://github.com/octo-technology/master-chef/tree/master/tests/json).
The description of what these config do is [here](https://github.com/octo-technology/master-chef/blob/master/tests/tests/what_is_tested.txt).

# Just one example

A `local.json` file to install [Jenkins](http://jenkins-ci.org/).

    {
      "repos": {
        "git": [
          "git://github.com/octo-technology/master-chef.git"
        ]
      },
      "run_list": [
        "recipe[base::system]",
        "recipe[master_chef::chef_solo_scripts]",
        "recipe[jenkins]"
      ],
      "node_config": {
      }
    }

Easy, is'nt it ?

# License

Copyright 2012 Bertrand Paquet / Octo Technology

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.