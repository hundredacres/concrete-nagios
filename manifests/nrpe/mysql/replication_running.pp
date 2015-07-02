class nagios::nrpe::mysql::replication_running (
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $nagios_alias           = $::hostname) {
  require nagios::nrpe::config
  include nagios::nrpe::service
  require nagios::nrpe::mysql::package

  file_line { 'check_replication_running':
    ensure => present,
    line   => "command[check_replication_running]=/usr/lib64/nagios/plugins/pmp-check-mysql-replication-running -w 0 -c 0",
    path   => '/etc/nagios/nrpe_local.cfg',
    match  => 'command\[check_replication_running\]',
    notify => Service['nrpe'],
  }

  @@nagios_service { "check_replication_running_${nagios_alias}":
    check_command       => 'check_nrpe_1arg!check_replication_running',
    use                 => $nagios_service,
    host_name           => $nagios_alias,
    target              => "/etc/nagios3/conf.d/puppet/service_${::fqdn}.cfg",
    service_description => "${nagios_alias}_check_replication_running",
    tag                 => $monitoring_environment,
  }

  @motd::register { 'Nagios Mysql Replication Running Check': }
}
