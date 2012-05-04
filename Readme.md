# Vagrant getting started script using Puppet

## Installation

    Install Vagrant
    $ cd ~/
    $ git clone https://github.com/shanecowherd/vagrant-puppet-railsstack.git
    $ cd vagrant-puppet-railsstack
    $ vagrant box add ubuntu1110 http://timhuegdon.com/vagrant-boxes/ubuntu-11.10.box
    $ vagrant up
    
## Change Mysql Password

    Edit the puppet/manifests/default.pp variables
