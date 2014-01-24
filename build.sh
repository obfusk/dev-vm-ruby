#!/bin/bash

set -xe

parent=precise64-cloud
box=dev-vm-ruby

export PARENT_BOX=yes

box_url='https://cloud-images.ubuntu.com/vagrant/precise/current/'
box_url+='precise-server-cloudimg-amd64-vagrant-disk1.box'

if ! vagrant box list | awk '{print $1}' | grep -qxF "$parent"; then
  vagrant box add "$parent" "$box_url"
fi

vagrant up
vagrant package --output "$box-$( date +%FT%T ).box"

[ "$KEEP" == yes ] && exit

vagrant destroy
