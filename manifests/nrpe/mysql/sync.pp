class nagios::nrpe::mysql::sync (
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $nagios_alias           = $::hostname) {
  require nagios::nrpe::config
  include nagios::nrpe::service
  require nagios::nrpe::mysql::package

  file_line { 'check_sync_status':
    ensure => present,
    line   => "command[check_sync_status]=/usr/lib64/nagios/plugins/pmp-check-mysql-status -x wsrep_local_state_comment -C '!=' -T str -w Synced",
    path   => '/etc/nagios/nrpe_local.cfg',
    match  => 'command\[check_sync_status\]',
    notify => Service['nrpe'],
  }

  @@nagios_service { "check_sync_status_${nagios_alias}":
    check_command       => 'check_nrpe_1arg!check_sync_status',
    use                 => $nagios_service,
    host_name           => $nagios_alias,
    target              => "/etc/nagios3/conf.d/puppet/service_${::fqdn}.cfg",
    service_description => "${nagios_alias}_check_sync_status",
    tag                 => $monitoring_environment,
  }

  @motd::register { 'Nagios Mysql Sync Check': }
}
