#!/bin/bash

set -xe

packages=(
  etckeeper git
  byobu curl grc htop tree vim
  build-essential ruby1.9.1-full

  zlib1g-dev libssl-dev libreadline-gplv2-dev
  libxml2-dev libxslt1-dev

  postgresql-contrib-9.1 postgresql-server-dev-9.1
  mongodb
  libsqlite3-dev sqlite3
  memcached redis-server

  imagemagick libmagickwand-dev
  nodejs

  nginx-full gitolite

  debian-goodies

  xclip vim-gtk
  chromium-browser firefox
)

passwd -l vagrant

aptitude update
aptitude -y safe-upgrade

aptitude install -y "${packages[@]}"

update-alternatives --set editor  /usr/bin/vim.basic
update-alternatives --set ruby    /usr/bin/ruby1.9.1
update-alternatives --set gem     /usr/bin/gem1.9.1

rm -f /etc/nginx/sites-enabled/default

service nginx restart

(
  cd /etc
  if ! test -e .git; then
    sed -ri '/^VCS="bzr"/ s!^!#!; /VCS="git"/ s!^#!!' \
      /etc/etckeeper/etckeeper.conf
    git init
    git add -A
    git commit -m ...
    git gc
    git status
  fi
)

cat <<__END | sed 's!^  !!' | sudo -H -u vagrant bash -xe
  cd
  mkdir -p bin opt/src

  (
    cd opt/src
    for x in sh-config dev-misc map.sh; do
      test -e "\$x" || \
      git clone https://github.com/obfusk/"\$x".git
    done
  )

  ln -fs opt/src/dev-misc/vimrc       .vimrc
  ln -fs ../opt/src/map.sh/bin/filter bin/filter
  ln -fs ../opt/src/map.sh/bin/map    bin/map

  grep -qF prompt.bash .bashrc || \
  sed 's!^  !!' >> .bashrc <<__END

    . ~/opt/src/sh-config/prompt.bash

  __END

  grep -qF LC_ALL .profile || \
  sed 's!^  !!' >> .profile <<__END

    for _path in \
      "\\\$HOME/.gem/ruby/1.9.1/bin" ;
    do
      [ -d "\\\$_path" ] && PATH="\\\$_path:\\\$PATH"
    done
    unset _path
    export LC_ALL=C LANG=C GEM_HOME="\\\$HOME/.gem/ruby/1.9.1"

  __END

  grep -qF no-ri .gemrc || \
  sed 's!^  !!' >> .gemrc <<__END
    install: --no-rdoc --no-ri
    update:  --no-rdoc --no-ri
  __END

  . .profile

  byobu-select-backend screen
  byobu-ctrl-a screen

  # git config --global user.name ...
  # git config --global user.email ...
  git config --global color.ui auto

  gem install bundler pry
__END
