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

  package { 'nagios-plugins-nrpe':
    ensure => installed,
    notify => Service['nagios'],
  }

  nagios_command { 'Check Nrpe Longtimeout':
    ensure       => 'present',
    command_name => 'check_nrpe_1arg_longtimeout',
    command_line => '/usr/lib/nagios/plugins/check_nrpe -H $HOSTADDRESS$ -c $ARG1$ -t 30',
    target       => '/etc/nagios/conf.d/puppet/command_nagios.cfg',
    notify       => Exec['rechmod'],
  }
}
