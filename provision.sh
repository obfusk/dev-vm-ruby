set -xe

: ${RELEASE:=trusty}

if ! dpkg -s ansible >/dev/null 2>&1; then
  apt-add-repository ppa:ansible/ansible -y
  aptitude update
  aptitude -y install ansible
fi
