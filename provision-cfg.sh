set -xe

before () { :; }
after  () { :; }

install_packages=() remove_packages=()

ruby=yes python=yes sqlite=yes memcached=yes redis=yes imagemagick=yes
nodejs=yes nginx=yes gitolite=yes vnc=yes X=yes

pg=ubuntu     # or pgdg for 9.3
mongo=ubuntu  # or 10gen for latest

editor=/usr/bin/vim.basic

user_name= user_email=
