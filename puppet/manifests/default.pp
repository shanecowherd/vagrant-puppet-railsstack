# -*- mode: ruby -*-
# vi: set ft=ruby :

$enable_apache          = true
$enable_mysql           = true
$enable_rails           = true
$enable_apt_get         = true

if $enable_apache {
  $simulated_web_url    = 'www.chadcargill.com' 
  include apache
  notice("Setting up apache")
  apache::vhost { 'localhost':
    port                => '80',
    docroot             => "/vagrant/$simulated_web_url/public",
    configure_firewall  => false,
  }
  host { $simulated_web_url:
    ip                  => '127.0.0.1',
  }
}

if $enable_mysql {
  $mysql_root_password  = 'foo'
  $mysql_database       = 'newdatabase'
  $mysql_user           = 'shane'
  $mysql_password       = 'pa$$word' 
  $simulated_mysql_url_source       = 'd.local.capturedknowledge.com' #address we are spoofing
  #$simulated_mysql_url_destination  = '184.106.236.198' #spoof address
  $simulated_mysql_url_destination = '10.0.2.2' #spoof address
  include mysql
  notice("Setting up mysql")
  class { 'mysql::server':
    config_hash         => {
      'root_password'   => $mysql_root_password,
      'bind_address'    => $::ipaddress
    }
  }
  mysql::db { $mysql_database:
    user                => $mysql_user,
    password            => $mysql_password,
    host                => '%',
    grant               => ['all'],
  } 
  host { $simulated_mysql_url_source:
    ip                  => $simulated_mysql_url_destination,
  }
}

if $enable_rails {
  $default_ruby_version = 'ruby-1.9.2-p290'  
  include rvm 
  notice("Setting up Ruby")
  package { "nodejs": ensure => present }
    #rvm::system_user { vagrant: ; shane: ; } - I'd use this in production and replace shane with a user
  rvm::system_user { vagrant: ; } #only used in vagrant because the default vagrant user is "vagrant"
  rvm_system_ruby {
    $default_ruby_version:
      ensure            => 'present',
      default_use       => true;
    'ruby-1.8.7-p357':
      ensure            => 'present',
      default_use       => false;
  }
  class {
    'rvm::passenger::apache':
      version           => '3.0.12',
      ruby_version      => $default_ruby_version,
      mininstances      => '3',
      maxinstancesperapp => '0',
      maxpoolsize       => '30',
      spawnmethod       => 'smart-lv2',
      require           => Rvm_system_ruby[$default_ruby_version];
  } 
  rvm_gemset {
    "$default_ruby_version@default":
      ensure            => present,
      require           => Rvm_system_ruby[$default_ruby_version];
  }
  rvm_gem {
    "$default_ruby_version/bundler":
      ensure            => '1.1.3',
      require           => Rvm_system_ruby[$default_ruby_version];
  }
  rvm_gem {
    "$default_ruby_version/puppet":
      ensure            => '2.7.13',
      require           => Rvm_system_ruby[$default_ruby_version]; 
  } 
  rvm_gem {
    "$default_ruby_version/rails":
      ensure            => '3.2.3',
      require           => Rvm_system_ruby[$default_ruby_version]; 
  } 
  rvm_gem {
    "$default_ruby_version/passenger":
      ensure            => '3.0.12',
      require           => Rvm_system_ruby[$default_ruby_version];  
  }

}
    
group { "puppet":
  ensure                => "present",
}

if $enable_apt_get {
  notice("Checking Apt-Get for updates")
  exec { "apt-get update":
    command             => "/usr/bin/apt-get update && touch /tmp/apt.update",
    onlyif              => "/bin/sh -c '[ ! -f /tmp/apt.update ] || /usr/bin/find /etc/apt -cnewer /tmp/apt.update | /bin/grep . > /dev/null'",
  }   
}
