# Using Vagrant

```bash
host$ vagrant up                                      # start
host$ vagrant ssh                                     # ssh to VM
host$ vagrant ssh -c 'byobu bash'                     # ssh to VM w/ byobu
host$ vagrant halt                                    # stop VM
```

# Byobu/Screen

```
ctrl-a      c   new window
ctrl-a      n   next window
ctrl-a      p   previous window
ctrl-a ctrl-a   switch between windows
ctrl-a      ?   help
ctrl-a      a   literal ctrl-a
ctrl-a      [   copy mode:
                  ctrl-b  page up
                  ctrl-f  page down
                  q       quit
                  space   select text
ctrl-a      ]   paste
```

# Shell

```
ctrl-a          beginning of line
ctrl-e          end of line
ctrl-d          exit (end of file)
```

# PostgreSQL

```bash
sudo -H -u postgres createuser -P $USERNAME           # password + 3x no
sudo -H -u postgres createdb $DBNAME -O $USERNAME
```

```bash
host$ pg_dump -h localhost -U $USERNAME -O $DBNAME > shared/$DBNAME.sql   # dump
vm$   psql    -h localhost -U $USERNAME    $DBNAME < shared/$DBNAME.sql   # restore
```

# Firefox & Chromium (in Screen Windows)

```bash
cd ~/projects/some/project
map 'screen $it' 'rails s' 'firefox localhost:3000' 'chromium-browser localhost:3000'
```

# Shares (Vagrantfile)

```ruby
'shared'                => '/home/vagrant/shared',
"#{Dir.home}/projects"  => '/home/vagrant/projects',
"#{Dir.home}/.apps"     => '/home/vagrant/.apps',
```

# Updates

```bash
sudo aptitude update                                  # update package lists
sudo aptitude safe-upgrade                            # upgrade packages
```

# Useful Programs

```bash
sudo aptitude install gedit-developer-plugins         # gedit editor
sudo aptitude install thunar                          # thunar file manager
```

# Port Forwarding

## Vagrant v1

```ruby
config.vm.forward_port 80, 8080
```

## Vagrant v2

```ruby
config.vm.network :forwarded_port, guest: 80, host: 8080
```

## Using SSH

```bash
host$ vagrant ssh-config > ssh-config
host$ ssh -F ssh-config -Nv -L 8080:localhost:80 default
```
