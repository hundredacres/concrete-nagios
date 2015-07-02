class nagios::nrpe::mysql::pidfile (
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $nagios_alias           = $::hostname) {
  require nagios::nrpe::config
  include nagios::nrpe::service
  require nagios::nrpe::mysql::package

  file_line { 'check_pidfile':
    ensure => present,
    line   => 'command[check_pidfile]=/usr/lib64/nagios/plugins/pmp-check-mysql-pidfile',
    path   => '/etc/nagios/nrpe_local.cfg',
    match  => 'command\[check_pidfile\]',
    notify => Service['nrpe'],
  }

  @@nagios_service { "check_pidfile_${nagios_alias}":
    check_command       => 'check_nrpe_1arg!check_pidfile',
    use                 => $nagios_service,
    host_name           => $nagios_alias,
    target              => "/etc/nagios3/conf.d/puppet/service_${::fqdn}.cfg",
    service_description => "${nagios_alias}_check_pidfile",
    tag                 => $monitoring_environment,
  }

  @motd::register { 'Nagios Mysql pidfile Check': }
}