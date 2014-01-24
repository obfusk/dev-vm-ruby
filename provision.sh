#!/bin/bash

set -xe

packages=(
  etckeeper git
  byobu curl grc htop tree vim
  build-essential ruby1.9.1-full
  xclip
  chromium-browser firefox
)

(
  cd /etc
  if ! test -e .git then
    sed -ri '/^VCS="bzr"/ s!^!#!; /VCS="git"/ s!^#!!' \
      /etc/etckeeper/etckeeper.conf
    git init
    git add -A
    git commit -m ...
    git gc
    git status
  fi
)

aptitude update
aptitude -y safe-upgrade

aptitude install -y -R "${packages[@]}"

update-alternatives --set editor  /usr/bin/vim.basic
update-alternatives --set ruby    /usr/bin/ruby1.9.1
update-alternatives --set gem     /usr/bin/gem1.9.1

cat <<__END | sed 's!^  !!' | sudo -H -u vagrant bash -xe
  cd
  mkdir -p bin opt/src

  (
    cd opt/src
    git clone https://github.com/obfusk/sh-config.git
    git clone https://github.com/obfusk/dev-misc.git
    git clone https://github.com/obfusk/map.sh.git
  )

  ln -s opt/src/dev-misc/vimrc        .vimrc
  ln -s ../opt/src/map.sh/bin/filter  bin/filter
  ln -s ../opt/src/map.sh/bin/map     bin/map

  sed 's!^  !!' >> .bashrc <<__END

    . ~/opt/src/sh-config/prompt.bash

  __END

  sed 's!^  !!' >> .profile <<__END

    for _path in \
      "\\\$HOME/.gem/ruby/1.9.1/bin" "\\\$HOME/bin" ;
    do
      [ -d "\\\$_path" ] && PATH="\\\$_path:\\\$PATH"
    done
    unset _path
    export LC_ALL=C GEM_HOME="\\\$HOME/.gem/ruby/1.9.1"

  __END

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
