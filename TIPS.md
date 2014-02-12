# Using Vagrant

```bash
host$ vagrant up                                      # start
host$ vagrant ssh                                     # ssh to VM
host$ vagrant ssh -c 'byobu bash'                     # ssh to VM w/ byobu
host$ vagrant halt                                    # stop VM
```

# Shares (Vagrantfile)

```ruby
'shared'                => '/home/vagrant/shared',
"#{Dir.home}/projects"  => '/home/vagrant/projects',
"#{Dir.home}/.apps"     => '/home/vagrant/.apps',
```

# ssh and git

You may want to generate (using `ssh-keygen`) a new ssh key for the VM
or copy your existing one (to `~/.ssh`).

# Updates

```bash
sudo aptitude update                                  # update package lists
sudo aptitude safe-upgrade                            # upgrade packages
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

# Port Forwarding

NB: vagrant's port forwarding will listen on all IP addresses (by
default), ssh will only listen on localhost (by default).

## cfg (Vagrantfile)

```ruby
8080 => 80
```

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
host$ ssh -F .ssh-config -Nv -L 8080:localhost:80 default
```

# Graphical Programs

If you trust the VM, you can use X forwarding to give it access to
your X server.  **Only use this if you trust the VM**, as it will have
access to e.g. your keystrokes.

Alternatively, you can use VNC.

## X forwarding

Enable `fwd_x` in the `Vagrantfile`.  Now you can start e.g. `firefox`
in the VM.

## VNC

1.  Run `vncserver -geometry 1280x800 :1 ; openbox &` to start the VNC
    server.
2.  Connect to the VNC server at `192.168.88.10:5901` using a remote
    desktop viewer.
3.  Run `vncserver -kill :1` to stop the VNC server.

# Useful Programs

```bash
mc                                                    # midnight commander file manager
nano
vim
ack
tig
grc
htop
tree
```

```bash
gvim
gedit
git gui
gitg
firefox
chromium-browser
xterm
xterm -e mc                                           # mc in xterm
```

# Firefox & Chromium (in Screen Windows)

```bash
cd ~/projects/some/project
map 'screen $it' 'rails s' 'firefox localhost:3000' 'chromium-browser localhost:3000'
```
