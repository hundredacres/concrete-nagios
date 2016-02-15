# == Class: nagios::server::check_mssql_health
#
# This is going to install the necessary nrpe plugin for checking mssql health
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com>
class nagios::server::plugins::check_mssql_health {
  require nagios::server::config
  include nagios::server::service

  ensure_resource('package', 'libdbd-sybase-perl', {
    'ensure' => 'installed'
  }
  )

  file { 'check_mssql_health':
    ensure => present,
    path   => '/usr/lib/nagios/plugins/check_mssql_health',
    source => 'puppet:///modules/nagios/server/plugins/check_mssql_health',
    owner  => 'nagios',
    group  => 'nagios',
    mode   => '0755',
  }

  nagios_command { 'check_mssql_health_custom':
    ensure       => 'present',
    command_name => 'check_mssql_health_custom',
    command_line => '/usr/lib/nagios/plugins/check_mssql_health --commit --server \'$ARG1$\' --username \'$ARG2$\' --password \'$ARG3$\' --name \'$ARG4$\' --mode \'$ARG5$\' --warning \'$ARG6$\' --critical \'$ARG7$\'',
    target       => '/etc/nagios/conf.d/puppet/command_nagios.cfg',
    notify       => Exec['rechmod'],
  }

  nagios_command { 'check_mssql_health_custom_noname':
    ensure       => 'present',
    command_name => 'check_mssql_health_custom_noname',
    command_line => '/usr/lib/nagios/plugins/check_mssql_health --commit --server \'$ARG1$\' --username \'$ARG2$\' --password \'$ARG3$\' --mode \'$ARG4$\' --warning \'$ARG5$\' --critical \'$ARG6$\'',
    target       => '/etc/nagios/conf.d/puppet/command_nagios.cfg',
    notify       => Exec['rechmod'],
  }
}