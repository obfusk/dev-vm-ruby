#!/bin/bash

set -xe
export LC_ALL=C

rsync -av --delete ansible/ shared/ansible/
vagrant ssh -c \
  'cd ~/shared/ansible && sudo ansible-playbook -v -i hosts site.yml'
