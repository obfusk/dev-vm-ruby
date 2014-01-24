shares = {
  'shared' => '/home/vagrant/shared',
}

require 'fileutils'

shares.each { |k,v| FileUtils.mkdir_p k }

Vagrant::Config.run('2') do |config|
  config.vm.box = ENV['PARENT_BOX'] == 'yes' ? 'precise64-cloud'
                                             : 'dev-vm-ruby'
  config.vm.provider 'virtualbox' do |v|
    v.customize ['modifyvm', :id, '--memory', 512]
  end
  config.vm.synced_folder '.', '/vagrant', disabled: true
  shares.each do |k,v|
    config.vm.synced_folder k, v, create: true
  end
  config.ssh.forward_x11 = true
  config.vm.provision :shell, :path => 'provision.sh'
end
