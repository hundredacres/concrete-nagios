class nagios::nrpe::mysql::user ($nagios_password) {
  require nagios::nrpe::config

  file { '/etc/nagios/mysql.cnf':
    ensure  => present,
    content => template('nagios/mysql.cnf'),
    owner   => 'nagios',
    group   => 'nagios',
    mode    => '0600',
  }
}