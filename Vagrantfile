ip        = '192.168.88.10'
priv_key  = './id_rsa'
shares    = {
  'shared'                => '/home/vagrant/shared',
# "#{Dir.home}/projects'  => '/home/vagrant/projects',
}

require 'fileutils'

shares.each { |k,v| FileUtils.mkdir_p k }

Vagrant::Config.run('2') do |config|
  if ENV['PARENT_BOX'] == 'yes'
    config.vm.box = 'precise64-cloud'
  else
    config.vm.box = 'dev-vm-ruby'
  end
  if ENV['OLD_KEY'] != 'yes'
    config.ssh.private_key_path = priv_key
  end
  config.vm.provider 'virtualbox' do |v|
    v.customize ['modifyvm', :id, '--memory', 512]
  end
  config.vm.network 'private_network', ip: ip
  config.vm.synced_folder '.', '/vagrant', disabled: true
  shares.each do |k,v|
    config.vm.synced_folder k, v, create: true
  end
  config.ssh.forward_x11 = true
  config.vm.provision :shell, :path => 'provision.sh'
end
