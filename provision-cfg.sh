set -xe

before () { :; }
after  () { :; }

install_packages=() remove_packages=()

ruby=yes python=yes sqlite=yes memcached=yes redis=yes imagemagick=yes
nginx=yes gitolite=yes phantomjs=yes vnc=yes X=yes

    pg=ubu  # or pgdg for 9.3
 mongo=ubu  # or 10gen for latest
nodejs=ubu  # or tar for latest

editor=/usr/bin/vim.basic

user_name= user_email=
