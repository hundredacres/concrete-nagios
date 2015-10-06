class nagios::server::plugins::nessus_reports (
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $nagios_alias           = $::hostname,
  $credentials_location   = '',
  $username               = 'root',
  $password) {
  require nagios::nrpe::config
  include nagios::nrpe::service

  file { 'check_nessus_reports.sh':
    ensure => present,
    path   => '/usr/lib/nagios/plugins/check_nessus_reports.sh',
    source => 'puppet:///modules/nagios/server/plugins/check_nessus_reports.sh',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  nagios_command { 'check_nessus_reports':
    ensure       => 'present',
    command_name => 'check_nessus_reports',
    command_line => '/usr/lib/nagios/plugins/check_nessus_report.sh -s $ARG1$ -C $ARG2$ -t $ARG3$ -w $ARG4$ -c $ARG5$',
    target       => '/etc/nagios3/conf.d/puppet/command_nagios.cfg',
    notify       => Exec['rechmod'],
  }

  if $credentials_location != '' {
    file { $credentials_location:
      ensure    => present,
      content   => template('nagios/server/plugins/credentials'),
      mode      => '0600',
      owner     => 'nagios',
      group     => 'nagios',
      show_diff => false
    }

  }

}