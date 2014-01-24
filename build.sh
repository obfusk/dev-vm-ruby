#!/bin/bash

set -xe

parent=precise64-cloud
box=dev-vm-ruby

export PARENT_BOX=yes

box_url='https://cloud-images.ubuntu.com/vagrant/precise/current/'
box_url+='precise-server-cloudimg-amd64-vagrant-disk1.box'

if ! test -e id_rsa; then
  if [ "$USE_MY_KEY" == yes ]; then
    ln -s "$HOME"/id_rsa
    ln -s "$HOME"/id_rsa.pub
  else
    ssh-keygen -f id_rsa -P ''
  fi
fi

if ! vagrant box list | awk '{print $1}' | grep -qxF "$parent"; then
  vagrant box add "$parent" "$box_url"
fi

export OLD_KEY=yes

vagrant up
vagrant ssh -c 'cat > ~/id_rsa.pub' < id_rsa.pub
vagrant ssh -c 'cp ~/id_rsa.pub ~/.ssh/authorized_keys'

export OLD_KEY=no

vagrant ssh -c 'sudo aptitude clean'
vagrant package --output "$box-$( date +%FT%T ).box"

[ "$KEEP" == yes ] || vagrant destroy
