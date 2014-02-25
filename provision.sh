set -xe

: ${RELEASE:=precise}

if ! dpkg -s ansible >/dev/null 2>&1; then
  if [ "$RELEASE" = precise ]; then
    sed 's!^    !!' > /etc/apt/sources.list.d/backports.list <<______END
      deb     http://archive.ubuntu.com/ubuntu $RELEASE-backports \
        main restricted universe
      deb-src http://archive.ubuntu.com/ubuntu $RELEASE-backports \
        main restricted universe
______END
  fi

  aptitude update
  aptitude -y -t $RELEASE-backports install ansible
fi
