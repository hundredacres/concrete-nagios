class nagios::server::plugins::check_mssql_health {
  require nagios::server::config
  include nagios::server::service

  package { 'libdbd-sybase-perl': ensure => installed, }

  file { 'check_mssql_health':
    ensure => present,
    path   => '/usr/lib/nagios/plugins/check_mssql_health',
    source => 'puppet:///modules/nagios/server/plugins/check_mssql_health',
    owner  => 'nagios',
    group  => 'nagios',
    mode   => '0755',
  }
  
  nagios_command { 'check_mssql':
    ensure       => 'present',
    command_name => 'check_mssql',
    command_line => '/usr/lib/nagios/plugins/check_mssql -H \'$ARG1$\' -U \'$ARG2$\' -P \'$ARG3$\' -q \'$ARG4$\' -d master -r \'OK\'',
    target       => '/etc/nagios3/conf.d/puppet/command_nagios.cfg',
    notify       => Exec['rechmod'],
  }

  nagios_command { 'check_mssql_long_timeout':
    ensure       => 'present',
    command_name => 'check_mssql_long_timeout',
    command_line => '/usr/lib/nagios/plugins/check_mssql -H \'$ARG1$\' -U \'$ARG2$\' -P \'$ARG3$\' -q \'$ARG4$\' -d master -r \'OK\' -w 10 -c 20',
    target       => '/etc/nagios3/conf.d/puppet/command_nagios.cfg',
    notify       => Exec['rechmod'],
  }
}