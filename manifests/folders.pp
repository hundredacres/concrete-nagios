# == Class: nagios::folders
#
# This creates the necessary folders for nagios.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com
class nagios::folders {
  case $::operatingsystem {
    'Ubuntu'         : {
      file { '/usr/lib/nagios/':
        ensure => directory,
        owner  => 'nagios',
        group  => 'nagios',
        mode   => '0755',
      }
    }
    'RHEL', 'CentOS' : {
      file { '/usr/lib/nagios/':
        ensure => link,
        target => '/usr/lib64/nagios',
        owner  => 'nagios',
        group  => 'nagios',
        mode   => '0755',
      }
    }
    default          : {
      err('Unsupported OS')
    }
  }

  file { '/usr/lib/nagios/plugins':
    ensure => directory,
    owner  => 'nagios',
    group  => 'nagios',
    mode   => '0755',
  }

  file { '/usr/lib/nagios/eventhandlers':
    ensure => directory,
    owner  => 'nagios',
    group  => 'nagios',
    mode   => '0755',
  }

}