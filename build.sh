#!/bin/bash

set -xe
export LC_ALL=C

parent=precise64-cloud
box=dev-vm-ruby

export PARENT_BOX=yes

box_url='https://cloud-images.ubuntu.com/vagrant/precise/current/'
box_url+='precise-server-cloudimg-amd64-vagrant-disk1.box'

if ! test -e id_rsa; then
  if test "$USE_MY_KEY" = yes; then
    ln -s "$HOME"/.ssh/id_rsa
    ln -s "$HOME"/.ssh/id_rsa.pub
  else
    ssh-keygen -f id_rsa -P '' -C "$box ($USER@$( hostname ))"
  fi
fi

if ! vagrant box list | awk '{print $1}' | grep -qxF "$parent"; then
  vagrant box add "$parent" "$box_url"
fi

export OLD_KEY=yes

vagrant up

cp id_rsa.pub shared/
vagrant ssh -c 'cp ~/shared/id_rsa.pub ~/.ssh/authorized_keys'
rm shared/id_rsa.pub

export OLD_KEY=no

./ansible.sh

vagrant ssh-config > .ssh-config
vagrant ssh -c 'sudo aptitude clean'

if test "$INTERACT" = yes; then
  vagrant ssh -c 'byobu bash'
  read -p 'press return... '
fi

[ "$PACKAGE"  = no  ] || vagrant package --output "$box-$( date +%FT%T ).box"
[ "$KEEP"     = yes ] || vagrant destroy
