base_cfg = {                                                    # {{{1
  name:     'default',
  release:  ENV['RELEASE'] || 'precise',
  box:      'dev-vm-ruby',
  host:     'dev-vm-ruby',
  ip:       '192.168.88.10',
  priv_key: './id_rsa',
  shares:   {
    'shared'                => '/home/vagrant/shared',
  # "#{Dir.home}/projects"  => '/home/vagrant/projects',
  },
  forwards: {
  # 8080 => 80,
  },
  custom: ['modifyvm', :id, '--memory', 512],
  fwd_x:  false,
  gui:    false,
}                                                               # }}}1

boxes = [
  {}, # defaults
]

require 'fileutils'
require 'tmpdir'

merge = -> h { base_cfg.merge h }

configure_boxes = -> config, vsn {
  boxes.each do |box|
    cfg   = merge[box]
    name  = ENV['CURRENT_BOX'] = cfg[:name]

    config.vm.define name do |config|
      cfg[:shares].each { |k,v| FileUtils.mkdir_p k }

      parent  = ENV['PARENT_BOX'] == 'yes'
      boxname = parent ? "#{cfg[:release]}64-cloud" : cfg[:box]

      f = -> config {                                           # {{{1
        config.vm.box = boxname
        if ENV['OLD_KEY'] != 'yes'
          config.ssh.private_key_path = cfg[:priv_key]
        end
        config.ssh.forward_x11 = cfg[:fwd_x]
        config.vm.provision :shell, :path => 'provision.sh' \
          if File.exists? 'provision.sh'
      }                                                         # }}}1

      Dir.mktmpdir do |tdir|
        if vsn == :v1                                           # {{{1
          f[config]
          config.vm.host_name = cfg[:host]
          config.vm.boot_mode = :gui if cfg[:gui]
          config.vm.customize cfg[:custom]
          config.vm.network :hostonly, cfg[:ip] \
            unless parent || !cfg[:ip]
          config.vm.share_folder 'v-root', '/.vagrant-shared',
            "#{tdir}/.shared", create: true
          cfg[:shares].each do |k,v|
            config.vm.share_folder k, v, k, create: true
          end
          cfg[:forwards].each do |k, v|
            config.vm.forward_port v, k
          end
        else                                                    # {{{1
          f[config]
          config.vm.hostname = cfg[:host]
          config.vm.provider :virtualbox do |vb|
            vb.gui = cfg[:gui]
            vb.customize cfg[:custom]
          end
          config.vm.network :private_network, ip: cfg[:ip] \
            unless parent || !cfg[:ip]
          config.vm.synced_folder '.', '/vagrant', disabled: true
          cfg[:shares].each do |k,v|
            config.vm.synced_folder k, v, create: true
          end
          cfg[:forwards].each do |k, v|
            config.vm.network :forwarded_port, guest: v, host: k
          end
        end                                                     # }}}1
      end
    end
  end
}

if Vagrant::VERSION =~ /^1\.0\./
  Vagrant::Config.run do |config|
    configure_boxes[config, :v1]
  end
else
  Vagrant::Config.run('2') do |config|
    configure_boxes[config, :v2]
  end
end
