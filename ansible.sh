#!/bin/bash

set -xe
export LC_ALL=C

rsync -e 'ssh -F .ssh-config' -av --delete ansible/ default:ansible/
vagrant ssh -c 'cd ~/ansible && ansible-playbook -v -i hosts site.yml'
