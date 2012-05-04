# -*- mode: ruby -*-
# vi: set ft=ruby :

$default_mysql_root_password = 'foo'
$default_mysql_database = 'newdatabase'
$default_mysql_user = 'shane'
$default_mysql_password = 'pa$$word'
$default_ruby_version = 'ruby-1.9.2-p290'
    
group { "puppet":
  ensure => "present",
}

exec { "apt-get update":
  command => "/usr/bin/apt-get update && touch /tmp/apt.update",
  onlyif => "/bin/sh -c '[ ! -f /tmp/apt.update ] || /usr/bin/find /etc/apt -cnewer /tmp/apt.update | /bin/grep . > /dev/null'",
}

include apache
include mysql
include rvm 

class apache { 
  package { "apache2": ensure => present } 
  service { "apache2": ensure => running } 
} 
#not used in this script, but I'm OCD and I want to be able to disable apache
class apache::disabled inherits apache { 
  Package["apache2"] { ensure => absent } 
  Service["apache2"] { ensure => stopped } 
}       
#not used in this script, but I'm OCD and I want to be able to remove apache
class apache::uninstall {
  package { 'apache2': ensure => purged }
  package { 'apache2-utils': ensure => purged }
  package { 'apache2.2-bin': ensure => purged }
  package { 'apache2.2-common': ensure => purged }
   
}

class { 'mysql::server':
  config_hash => {
    'root_password' => $default_mysql_root_password,
    'bind_address'  => $::ipaddress
  }
}


mysql::db { $default_mysql_database:
  user     => $default_mysql_user,
  password => $default_mysql_password,
  host     => '%',
  grant    => ['all'],
}

#rvm::system_user { vagrant: ; shane: ; } - I'd use this in production and replace shane with a user
rvm::system_user { vagrant: ; } #only used in vagrant because the default vagrant user is "vagrant"
rvm_system_ruby {
  $default_ruby_version:
    ensure => 'present',
    default_use => true;
  'ruby-1.8.7-p357':
    ensure => 'present',
    default_use => false;
}
rvm_gemset {
  "$default_ruby_version@default":
    ensure => present,
    require => Rvm_system_ruby[$default_ruby_version];
}
#INSTALL GEMS!! bundler/puppet/rails (you can add your own just make a new rvm_gem {} )
rvm_gem {
  "$default_ruby_version/bundler":
    ensure => '1.0.21',
    require => Rvm_system_ruby[$default_ruby_version];
}
rvm_gem {
  "$default_ruby_version/puppet":
    ensure => '2.7.13',
    require => Rvm_system_ruby[$default_ruby_version]; 
} 
rvm_gem {
  "$default_ruby_version/rails":
    ensure => '3.0',
    require => Rvm_system_ruby[$default_ruby_version]; 
} 


