class nagios::server::plugins::check_mssql_health {
  package { 'libdbd-sybase-perl': ensure => installed, }

  file { 'check_mssql_health':
    ensure => present,
    path   => '/usr/lib/nagios/plugins/check_mssql_health',
    source => 'puppet:///modules/nagios/server/plugins/check_mssql_health',
    owner  => 'nagios',
    group  => 'nagios',
    mode   => '0755',
  }
}