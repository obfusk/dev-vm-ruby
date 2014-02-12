set -xe

umask 022

packages=( # {{{
  etckeeper git
  byobu curl grc htop tree vim
  ack-grep mc tig
  build-essential debian-goodies

  zlib1g-dev libssl-dev libreadline-gplv2-dev
  libxml2-dev libxslt1-dev
)

       ruby_packages=( ruby1.9.1-full )
     python_packages=( python-virtualenv python-dev )
     sqlite_packages=( libsqlite3-dev sqlite3 )
  memcached_packages=( memcached )
      redis_packages=( redis-server )
imagemagick_packages=( imagemagick libmagickwand-dev )
     nodejs_packages=( nodejs )
      nginx_packages=( nginx-full )
   gitolite_packages=( gitolite )
  phantomjs_packages=( phantomjs )
        vnc_packages=( tightvncserver openbox )

x_packages=(
  xclip vim-gtk xterm
  gitg git-gui gitk
  chromium-browser firefox
  gedit-developer-plugins
  bzr- zeitgeist-
) # }}}

case "$pg" in # {{{
ubu)
  pg_packages=( postgresql-contrib-9.1 postgresql-server-dev-9.1 )
  pg_prep () { :; }
;;
pgdg)
  pg_packages=( postgresql-contrib-9.3 postgresql-server-dev-9.3 )
  pg_prep () {
    s=61826981fb91bc3cc4ad870be465d09b2f295eb10f3106128984bdc28d9d848f48ed00f61e1ca6411b6eaef750284e24ca9e9db86ec91f279ac9098ec0e85ffd
    f="$( mktemp )"
    curl "https://www.postgresql.org/media/keys/ACCC4CF8.asc" > "$f"
    if ! test "$( sha512sum "$f" | awk '{print $1}' )" = "$s"; then
      echo "shasum does not match" >&2; exit 1
    fi
    apt-key add "$f"; rm -f "$f"
    sed 's!^      !!' > /etc/apt/sources.list.d/pgdg.list <<______END
      deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main
______END
    sed 's!^      !!' > /etc/apt/preferences.d/pgdg.pref <<______END
      Package: *
      Pin: release o=apt.postgresql.org
      Pin-Priority: 200

      Package: postgres* libpq*
      Pin: release o=apt.postgresql.org
      Pin-Priority: 500
______END
  }
;;
no)
  pg_packages=()
  pg_prep () { :; }
;;
*)
  echo "unexpected \$pg: $pg" >&2; exit 1
;;
esac # }}}

case "$mongo" in # {{{
ubu)
  mongo_packages=( mongodb )
  mongo_prep () { :; }
  mongo_fix  () { :; }
;;
10gen)
  mongo_packages=( mongodb-10gen )
  mongo_prep () {
    s=1671ba18b69c022201821e81c0d4f9c27e3edde05adffbc334f2f6bd6467aedbb7f7fda8a21728a94d13c6e7d8f59b3941b28f034d147e0e0446018de8f49310
    f="$( mktemp )"
    curl "http://docs.mongodb.org/10gen-gpg-key.asc" > "$f"
    if ! test "$( sha512sum "$f" | awk '{print $1}' )" = "$s"; then
      echo "shasum does not match" >&2; exit 1
    fi
    apt-key add "$f"; rm -f "$f"
    sed 's!^      !!' > /etc/apt/sources.list.d/mongodb.list <<______END
      deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen
______END
    sed 's!^      !!' > /etc/apt/preferences.d/mongodb.pref <<______END
      Package: *
      Pin: release o=10gen
      Pin-Priority: 200
______END
  }
  mongo_fix () {
    grep -qF bind_ip /etc/mongodb.conf || \
    sed -i '/port *=/i \bind_ip = 127.0.0.1' /etc/mongodb.conf
    service mongodb restart
  }
;;
no)
  mongo_packages=()
  mongo_prep () { :; }
  mongo_fix  () { :; }
;;
*)
  echo "unexpected \$mongo: $mongo" >&2; exit 1
;;
esac # }}}

rm_packages=( rpcbind cloud-init )

git_obfusk=( sh-config dev-misc map.sh taskmaster venv)
git_other=( kchmck/vim-coffee-script plasticboy/vim-markdown )

links () { # {{{
  ln -fs /opt/src/map.sh/bin/filter       /usr/local/bin/filter
  ln -fs /opt/src/map.sh/bin/map          /usr/local/bin/map
  ln -fs /opt/src/taskmaster/taskmaster   /usr/local/bin/taskmaster
  ln -fs /opt/src/venv/venv               /usr/local/bin/venv
  ln -fs /usr/bin/ack-grep                /usr/local/bin/ack
} # }}}

user_links="
  ln -fs /opt/src/dev-misc/vimrc .vimrc
"

# --

before

passwd -l vagrant
aptitude update; aptitude -y safe-upgrade

pkgs=( "${packages[@]}" ) # {{{

[ "$ruby"        != yes ] || pkgs+=( "${ruby_packages[@]}"        )
[ "$python"      != yes ] || pkgs+=( "${python_packages[@]}"      )
[ "$sqlite"      != yes ] || pkgs+=( "${sqlite_packages[@]}"      )
[ "$memcached"   != yes ] || pkgs+=( "${memcached_packages[@]}"   )
[ "$redis"       != yes ] || pkgs+=( "${redis_packages[@]}"       )
[ "$imagemagick" != yes ] || pkgs+=( "${imagemagick_packages[@]}" )
[ "$nginx"       != yes ] || pkgs+=( "${nginx_packages[@]}"       )
[ "$gitolite"    != yes ] || pkgs+=( "${gitolite_packages[@]}"    )
[ "$phantomjs"   != yes ] || pkgs+=( "${phantomjs_packages[@]}"   )
[ "$vnc"         != yes ] || pkgs+=( "${vnc_packages[@]}"         )
[ "$X"           != yes ] || pkgs+=( "${x_packages[@]}"           )

[ "$nodejs"      != ubu ] || pkgs+=( "${nodejs_packages[@]}"      )
# }}}

pg_prep; mongo_prep; aptitude update

aptitude install -y "${pkgs[@]}" "${install_packages[@]}" \
  "${pg_packages[@]}" "${mongo_packages[@]}"
aptitude purge -y "${rm_packages[@]}" "${remove_packages[@]}"

mongo_fix

( # {{{
  mkdir -p /opt/src /opt/pkg
  cd /opt/src
  for x in "${git_obfusk[@]}"; do
    test -e "$x" || git clone https://github.com/obfusk/"$x".git
  done
  for x in "${git_other[@]}"; do
    test -e "$( basename "$x" )" || git clone https://github.com/"$x".git
  done
) # }}}

if test "$nodejs" = tar; then ( # {{{
  cd /opt/pkg
  s=01eff016df73931fc1b289fc7028fc1ec7eb902890c03f88c70bfbbb3d5e5b0f7f01517f02f4dc28188c9dd507886bf9c1b799b6c88e9d9454a68f98afc17557
  v=v0.10.25
  d=node-"$v"-linux-x64
  if ! test -e "$d"; then
    f="$( mktemp )"
    curl "http://nodejs.org/dist/$v/node-$v-linux-x64.tar.gz" > "$f"
    if ! test "$( sha512sum "$f" | awk '{print $1}' )" = "$s"; then
      echo "shasum does not match" >&2; exit 1
    fi
    mkdir tmp tmp/extract; chmod 700 tmp tmp/extract
    (
      cd tmp/extract
      tar --no-same-owner --no-same-permissions -x -f "$f"
      chk="$( find -not -type l \( -perm /7022 -o -not -user 0 \
                                   -o -not -group 0 \) )"
      if ! test "$chk" = ''; then
        echo 'F*CK!' >&2; exit 1
      fi
      mv "$d" ../../
    )
    rmdir -p tmp/extract
    rm -f "$f"
  fi
  ln -fs "$d" node
  ln -fs /opt/pkg/node/bin/node /usr/local/bin/node
  ln -fs /opt/pkg/node/bin/npm  /usr/local/bin/npm
) fi # }}}

links

update-alternatives --set editor "$editor"

if test "$ruby" != no; then
  update-alternatives --set ruby  /usr/bin/ruby1.9.1
  update-alternatives --set gem   /usr/bin/gem1.9.1
fi

if test "$nginx" != no; then
  rm -f /etc/nginx/sites-enabled/default
  service nginx restart
fi

( # {{{
  cd /etc
  if ! test -e .git; then
    sed -ri '/^VCS="bzr"/ s!^!#!; /VCS="git"/ s!^#!!' \
      /etc/etckeeper/etckeeper.conf
    git init; git add -A; git commit -m ...; git gc; git status
  fi
) # }}}

cat <<__END | sed 's!^  !!' | sudo -H -u vagrant bash -xe # {{{
  cd

  $user_links

  grep -qF prompt.bash .bashrc || \
  sed 's!^  !!' >> .bashrc <<__END

    . /opt/src/sh-config/prompt.bash

  __END

  grep -qF LC_ALL .profile || \
  sed 's!^  !!' >> .profile <<__END # {{{

    for _path in \\
      "\\\$HOME/.node/bin" "\\\$HOME/.gem/ruby/1.9.1/bin" ;
    do
      [ -d "\\\$_path" ] && PATH="\\\$_path:\\\$PATH"
    done
    unset _path

    export LC_ALL=C LANG=C GEM_HOME="\\\$HOME/.gem/ruby/1.9.1"
    export NODE_PATH="\\\$HOME/.node/lib/node_modules"

    [ -z "\\\$DISPLAY" ] && export DISPLAY=:1

  __END
  # }}}

  grep -qF no-ri .gemrc || \
  sed 's!^  !!' >> .gemrc <<__END
    install: --no-rdoc --no-ri
    update:  --no-rdoc --no-ri
  __END

  grep -qF prefix .npmrc || \
  sed 's!^  !!' >> .npmrc <<__END
    prefix = ~/.node
    unicode = false
  __END

  mkdir -p "\$HOME/bin" "\$HOME/.node/bin" "\$HOME/.gem/ruby/1.9.1/bin"

  . .profile

  byobu-select-backend screen
  byobu-ctrl-a screen

  [ -z "$user_name"  ] || git config --global user.name "$user_name"
  [ -z "$user_email" ] || git config --global user.email "$user_email"
  git config --global color.ui auto

  [ ! -x "\$( which gem )" ] || gem install bundler pry
  [ ! -x "\$( which npm )" ] || npm -g install coffee-script
__END
# }}}

after
