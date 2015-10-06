class nagios::server::plugins::check_mssql_health {
  package { 'libdbd-sybase-perl': ensure => installed, }

  file { 'event_handler.sh':
    ensure => present,
    path   => '/usr/lib/nagios/eventhandlers/check_mssql_health',
    source => 'puppet:///modules/nagios/server/plugins/check_mssql_health',
    owner  => 'nagios',
    group  => 'nagios',
    mode   => '0755',
  }
}