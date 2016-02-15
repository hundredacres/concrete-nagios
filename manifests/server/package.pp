# == Class: nagios::server::package
#
<<<<<<< HEAD
# This is going to install the nagios package.
=======
# This is going to install the nagios3 package.
>>>>>>> 1e86654231d7c29360426c7db6fb721c0f31061c
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com>
class nagios::server::package {
  include nagios::folders

<<<<<<< HEAD
  package { 'nagios':
=======
  package { 'nagios3':
>>>>>>> 1e86654231d7c29360426c7db6fb721c0f31061c
    ensure => installed,
    before => File['/usr/lib/nagios/eventhandlers']
  }

}
