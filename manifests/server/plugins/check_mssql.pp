# == Class: nagios::server::check_mssql
#
# This is going to install the necessary nrpe plugin for running stored
# procedures as a nagios check. It will also set up some basic commands to run
# checks.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com>
class nagios::server::plugins::check_mssql {
  require nagios::server::config
  include nagios::server::service

  ensure_resource('package', 'php5-sybase', {
    'ensure' => 'installed'
  }
  )

  file { 'check_mssql':
    ensure => present,
    path   => '/usr/lib/nagios/plugins/check_mssql',
    source => 'puppet:///modules/nagios/server/plugins/check_mssql',
    owner  => 'nagios',
    group  => 'nagios',
    mode   => '0755',
  }

  nagios_command { 'check_mssql':
    ensure       => 'present',
    command_name => 'check_mssql',
    command_line => '/usr/lib/nagios/plugins/check_mssql -H \'$ARG1$\' -U \'$ARG2$\' -P \'$ARG3$\' -q \'$ARG4$\' -d \'$ARG5$\' -r \'OK\'',
    target       => '/etc/nagios3/conf.d/puppet/command_nagios.cfg',
    notify       => Exec['rechmod'],
  }

  nagios_command { 'check_mssql_long_timeout':
    ensure       => 'present',
    command_name => 'check_mssql_long_timeout',
    command_line => '/usr/lib/nagios/plugins/check_mssql -H \'$ARG1$\' -U \'$ARG2$\' -P \'$ARG3$\' -q \'$ARG4$\' -d \'$ARG5$\' -r \'OK\' -w 10 -c 20',
    target       => '/etc/nagios3/conf.d/puppet/command_nagios.cfg',
    notify       => Exec['rechmod'],
  }
}