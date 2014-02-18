[]: {{{1

    File        : README.md
    Maintainer  : Felix C. Stegerman <flx@obfusk.net>
    Date        : 2014-02-18

    Copyright   : Copyright (C) 2014  Felix C. Stegerman

[]: }}}1

## Description
[]: {{{1

  dev-vm-ruby - ruby development VM (scripts)

### Security

[]: {{{2

  **NB**: vagrant **is very insecure** by default.  Older versions run
  ssh listening on all IP addresses -- newer versions still listen on
  localhost; publicly known ssh keys and passwords are used; the
  directory containing the Vagrantfile is shared read-write with the
  VM by default, allowing the guest to compromise the host.

  I've taken steps to mitigate these risks, but you should be very
  careful and review the security yourself.

  The supplied Vagrantfile should disable the default share; you
  should be very careful when adding additional shares.

  The build script will replace the default ssh keys and the
  provisioning script will lock the user password, but -- until the VM
  is built -- someone with access to the VM via ssh (which could be
  anyone on your local network with older versions of vagrant) could
  still compromise the VM using the default keys/password.

#### Services

  Make sure you don't run any services on your computer or network
  that you don't want the VM to be able to access.

#### When Using VNC

  The VNC server port will be forwarded to localhost (port 5901).  You
  should probably use a firewall and a single-user system to keep
  others out.

[]: }}}2

### Usage

  NB: you should install virtualbox and vagrant via your package
  manager if possible.

  1.  Install [virtualbox](https://www.virtualbox.org)
  2.  Install [vagrant](https://www.vagrantup.com)
  3.  Download the .zip or `git clone`
  4.  Modify the `Vagrantfile` (if needed)
  5.  If you don't already have a pre-built dev-vm-ruby base box, run
      `./build.sh` (this will also generate an ssh key pair)
  6.  `vagrant box add dev-vm-ruby /path/to/.box` the base box
  7.  `vagrant up`
  8.  `vagrant ssh -c 'byobu bash'`
  9.  ???
  10. profit!

[]: }}}1

## TODO

  * refactor ansible config
  * test test test

## License

  GPLv3+ [1].

## References

  [1] GNU General Public License, version 3
  --- http://www.gnu.org/licenses/gpl-3.0.html

[]: ! ( vim: set tw=70 sw=2 sts=2 et fdm=marker : )
