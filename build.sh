#!/bin/bash

set -xe

vagrant package --output "dev-vm-ruby-$( date +%FT%T ).box"
