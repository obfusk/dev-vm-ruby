set -xe

packages=( # {{{
  etckeeper git
  byobu curl grc htop tree vim mc ack-grep
  build-essential debian-goodies

  zlib1g-dev libssl-dev libreadline-gplv2-dev
  libxml2-dev libxslt1-dev
) # }}}

       ruby_packages=( ruby1.9.1-full )
     sqlite_packages=( libsqlite3-dev sqlite3 )
  memcached_packages=( memcached )
      redis_packages=( redis-server )
imagemagick_packages=( imagemagick libmagickwand-dev )
     nodejs_packages=( nodejs )
      nginx_packages=( nginx-full )
   gitolite_packages=( gitolite )
        vnc_packages=( tightvncserver openbox )

x_packages=(
  xclip vim-gtk xterm chromium-browser firefox gedit-developer-plugins
)

case "$pg" in # {{{
ubuntu)
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
      echo "shasum does not match" >&2
      exit 1
    fi
    apt-key add "$f"
    sed 's!^      !!' > /etc/apt/sources.list.d/pgdg.list <<______END
      deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main
______END
    sed 's!^      !!' > /etc/apt/preferences.d/pgdg.pref <<______END
      Package: *
      Pin: release o=apt.postgresql.org
      Pin-Priority: 200
______END
  }
;;
no)
  pg_packages=()
  pg_prep () { :; }
;;
*)
  echo "unexpected \$pg: $pg" >&2
  exit 1
;;
esac # }}}

case "$mongo" in # {{{
ubuntu)
  mongo_packages=( mongodb )
  mongo_prep () { :; }
;;
10gen)
  mongo_packages=( mongodb-10gen )
  mongo_prep () {
    s=1671ba18b69c022201821e81c0d4f9c27e3edde05adffbc334f2f6bd6467aedbb7f7fda8a21728a94d13c6e7d8f59b3941b28f034d147e0e0446018de8f49310
    f="$( mktemp )"
    curl "http://docs.mongodb.org/10gen-gpg-key.asc" > "$f"
    if ! test "$( sha512sum "$f" | awk '{print $1}' )" = "$s"; then
      echo "shasum does not match" >&2
      exit 1
    fi
    apt-key add "$f"
    sed 's!^      !!' > /etc/apt/sources.list.d/mongodb.list <<______END
      deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen
______END
    sed 's!^      !!' > /etc/apt/preferences.d/mongodb.pref <<______END
      Package: *
      Pin: release o=10gen
      Pin-Priority: 200
______END
;;
no)
  mongo_packages=()
  mongo_prep () { :; }
;;
*)
  echo "unexpected \$mongo: $mongo" >&2
  exit 1
;;
esac # }}}

rm_packages=( rpcbind cloud-init )

passwd -l vagrant
aptitude update; aptitude -y safe-upgrade

pkgs=( "${packages[@]}" )

[ "$ruby"         = no ] || pkgs+=( "${ruby_packages[@]}"         )
[ "$sqlite"       = no ] || pkgs+=( "${sqlite_packages[@]}"       )
[ "$memcached"    = no ] || pkgs+=( "${memcached_packages[@]}"    )
[ "$redis"        = no ] || pkgs+=( "${redis_packages[@]}"        )
[ "$imagemagick"  = no ] || pkgs+=( "${imagemagick_packages[@]}"  )
[ "$nodejs"       = no ] || pkgs+=( "${nodejs_packages[@]}"       )
[ "$nginx"        = no ] || pkgs+=( "${nginx_packages[@]}"        )
[ "$gitolite"     = no ] || pkgs+=( "${gitolite_packages[@]}"     )
[ "$vnc"          = no ] || pkgs+=( "${vnc_packages[@]}"          )
[ "$X"            = no ] || pkgs+=( "${x_packages[@]}"            )

pg_prep; mongo_prep; aptitude update

aptitude install -y "${pkgs[@]}" "${pg_packages[@]}" "${mongo_packages[@]}"
aptitude purge -y "${rm_packages[@]}"

update-alternatives --set editor /usr/bin/vim.basic

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
  mkdir -p bin opt/src

  ( # {{{
    cd opt/src
    for x in sh-config dev-misc map.sh; do
      test -e "\$x" || git clone https://github.com/obfusk/"\$x".git
    done
  ) # }}}

  ln -fs opt/src/dev-misc/vimrc       .vimrc
  ln -fs ../opt/src/map.sh/bin/filter bin/filter
  ln -fs ../opt/src/map.sh/bin/map    bin/map
  ln -fs /usr/bin/ack-grep            bin/ack

  grep -qF prompt.bash .bashrc || \
  sed 's!^  !!' >> .bashrc <<__END

    . ~/opt/src/sh-config/prompt.bash

  __END

  grep -qF LC_ALL .profile || \
  sed 's!^  !!' >> .profile <<__END # {{{

    for _path in \
      "\\\$HOME/.gem/ruby/1.9.1/bin" ;
    do
      [ -d "\\\$_path" ] && PATH="\\\$_path:\\\$PATH"
    done
    unset _path

    export LC_ALL=C LANG=C GEM_HOME="\\\$HOME/.gem/ruby/1.9.1"

    [ -z "\\\$DISPLAY" ] && export DISPLAY=:1

  __END
  # }}}

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

  [ ! -x "\$( which gem ) ] || gem install bundler pry
__END
# }}}
