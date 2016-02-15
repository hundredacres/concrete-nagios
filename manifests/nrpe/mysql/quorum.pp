# == Define: nagios::nrpe::mysql::quorum
#
# This is going to implement the percona mysql status check in order to check
# that a mysql cluster has the correct quorum.
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
#   class { ::nagios::nrpe::mysql::quorum :
#   }
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com>
class nagios::nrpe::mysql::quorum (
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $nagios_alias           = $::hostname) {
  require nagios::nrpe::config
  include nagios::nrpe::service
  require nagios::nrpe::mysql::package

  file_line { 'check_quorum_status':
    ensure => present,
    line   => 'command[check_quorum_status]=/usr/lib64/nagios/plugins/pmp-check-mysql-status -x wsrep_cluster_status -C == -T str -c non-Primary',
    path   => '/etc/nagios/nrpe_local.cfg',
    match  => 'command\[check_quorum_status\]',
    notify => Service['nrpe'],
  }

  @@nagios_service { "check_quorum_status_${nagios_alias}":
    check_command       => 'check_nrpe_1arg!check_quorum_status',
    use                 => $nagios_service,
    host_name           => $nagios_alias,
<<<<<<< HEAD
    target              => "/etc/nagios/conf.d/puppet/service_${nagios_alias}.cfg",
=======
    target              => "/etc/nagios3/conf.d/puppet/service_${nagios_alias}.cfg",
>>>>>>> 1e86654231d7c29360426c7db6fb721c0f31061c
    service_description => "${nagios_alias}_check_quorum_status",
    tag                 => $monitoring_environment,
  }
}
