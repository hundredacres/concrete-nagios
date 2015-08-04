# == Class: nagios::server::nrpe
#
# This is going to install the necessary nrpe plugin for nagios
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com>
class nagios::server::nrpe {
  require nagios::server::config
  include nagios::server::service

  package { 'nagios-nrpe-plugin':
    ensure => installed,
    notify => Service['nagios3'],
  }

}
