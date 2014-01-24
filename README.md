[]: {{{1

    File        : README.md
    Maintainer  : Felix C. Stegerman <flx@obfusk.net>
    Date        : 2014-01-24

    Copyright   : Copyright (C) 2014  Felix C. Stegerman

[]: }}}1

## Description
[]: {{{1

  dev-vm-ruby - ruby development VM (scripts)

  1. Install [virtualbox](https://www.virtualbox.org)*
  2. Install [vagrant](https://www.vagrantup.com)*
  3. Download the .zip or `git clone`
  4. Modify the `Vagrantfile` (if needed)
  5. Download a pre-built dev-vm base box or `./build.sh`
  6. `vagrant box add dev-vm-ruby /path/to/.box` the base box
  7. `vagrant up`
  8. `vagrant ssh -c 'byobu bash'`
  9. ???
  10. profit!

#

  \* may also be available via your package manager

[]: }}}1

## License

  GPLv3+ [1].

## References

  [1] GNU General Public License, version 3
  --- http://www.gnu.org/licenses/gpl-3.0.html

[]: ! ( vim: set tw=70 sw=2 sts=2 et fdm=marker : )
