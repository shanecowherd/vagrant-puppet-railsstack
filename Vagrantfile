# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.box = "ubuntu1110"
  # config.vm.network :hostonly, "192.168.33.10"
  # config.vm.network :bridged
  config.vm.forward_port 80, 8081
  config.vm.forward_port 3306, 13306
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.module_path    = "puppet/modules"
    #puppet.manifest_file  = "ubuntu1110.pp"
  end
  
end
