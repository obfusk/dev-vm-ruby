set -xe

if ! dpkg -s ansible >/dev/null 2>&1; then
  sed 's!^    !!' > /etc/apt/sources.list.d/backports.list <<____END
    deb     http://archive.ubuntu.com/ubuntu precise-backports \
      main restricted universe
    deb-src http://archive.ubuntu.com/ubuntu precise-backports \
      main restricted universe
____END

  aptitude update
  aptitude -y -t precise-backports install ansible
fi
