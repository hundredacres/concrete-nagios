# == Define: nagios::nrpe::mysql::sync
#
# This is going to implement the percona mysql status check which will check the
# galera sync status to ensure it is working correctly.
#
# === Parameters
#
# [*monitoring_environment*]
#   This is the environment that the check will be submitted for. This will
#   default to the value set by nagios::nrpe::config but can be overridden here.
#   Not required.
#
# [*nagios_service*]
#   This is the generic service that this check will implement. This should
#   be set by nagios::nrpe::config but can be overridden here. Not required.
#
# [*nagios_alias*]
#   This is the hostname that the check will be submitted for. This should
#   almost always be the hostname, but could be overriden, for instance when
#   submitting a check for a virtual ip.
#
# === Examples
#
#   class { ::nagios::nrpe::mysql::sync :
#   }
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com>
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
    target              => "/etc/nagios/conf.d/puppet/service_${nagios_alias}.cfg",
    service_description => "${nagios_alias}_check_sync_status",
    tag                 => $monitoring_environment,
  }
}
