set -xe

sed 's!^  !!' > /etc/apt/sources.list.d/backports.list <<__END
  deb     http://archive.ubuntu.com/ubuntu precise-backports \
    main restricted universe
  deb-src http://archive.ubuntu.com/ubuntu precise-backports \
    main restricted universe
__END

aptitude update
aptitude -y -t precise-backports install ansible

cd ~vagrant/shared/ansible
ansible -i hosts main.yml
