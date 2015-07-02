class nagios::nrpe::mysql::processlist (
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $nagios_alias           = $::hostname) {
  require nagios::nrpe::config
  include nagios::nrpe::service
  require nagios::nrpe::mysql::package

  file_line { 'check_processlist':
    ensure => present,
    line   => 'command[check_processlist]=/usr/lib64/nagios/plugins/pmp-check-mysql-processlist',
    path   => '/etc/nagios/nrpe_local.cfg',
    match  => 'command\[check_processlist\]',
    notify => Service['nrpe'],
  }

  @@nagios_service { "check_processlist_${nagios_alias}":
    check_command       => 'check_nrpe_1arg!check_processlist',
    use                 => $nagios_service,
    host_name           => $nagios_alias,
    target              => "/etc/nagios3/conf.d/puppet/service_${::fqdn}.cfg",
    service_description => "${nagios_alias}_check_processlist",
    tag                 => $monitoring_environment,
  }

  @motd::register { 'Nagios Mysql Processlist Check': }
}