# == Class: nagios::server::nrpe
#
# This is going to install the necessary nrpe plugin for nagios
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com>
class nagios::server::plugins::nrpe {
  require nagios::server::config
  include nagios::server::service

<<<<<<< HEAD
  package { 'nagios-plugins-nrpe':
    ensure => installed,
    notify => Service['nagios'],
=======
  package { 'nagios-nrpe-plugin':
    ensure => installed,
    notify => Service['nagios3'],
>>>>>>> 1e86654231d7c29360426c7db6fb721c0f31061c
  }

  nagios_command { 'Check Nrpe Longtimeout':
    ensure       => 'present',
    command_name => 'check_nrpe_1arg_longtimeout',
    command_line => '/usr/lib/nagios/plugins/check_nrpe -H $HOSTADDRESS$ -c $ARG1$ -t 30',
<<<<<<< HEAD
    target       => '/etc/nagios/conf.d/puppet/command_nagios.cfg',
=======
    target       => '/etc/nagios3/conf.d/puppet/command_nagios.cfg',
>>>>>>> 1e86654231d7c29360426c7db6fb721c0f31061c
    notify       => Exec['rechmod'],
  }
}
