# == Class: nagios::server::package
#
# This is going to install the nagios package.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com>
class nagios::server::package {
  include nagios::folders

  package { 'nagios':
    ensure => installed,
    before => File['/usr/lib/nagios/eventhandlers']
  }

}
