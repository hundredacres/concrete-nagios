# == Define: nagios::nrpe::mysql::flow_control
#
# This is going to implement the percona mysql flow control check which checks
# how much flow control is being used by the galera replication.
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
#   class { ::nagios::nrpe::mysql::flow_control:
#   }
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com>
class nagios::nrpe::mysql::flow_control (
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $nagios_alias           = $::hostname) {
  require nagios::nrpe::config
  include nagios::nrpe::service
  require nagios::nrpe::mysql::package

  file_line { 'check_flow_control':
    ensure => present,
    line   => 'command[check_flow_control]=/usr/lib64/nagios/plugins/pmp-check-mysql-status -x wsrep_flow_control_paused -w 0.1 -c 0.9',
    path   => '/etc/nagios/nrpe_local.cfg',
    match  => 'command\[check_flow_control\]',
    notify => Service['nrpe'],
  }

  @@nagios_service { "check_flow_control_${nagios_alias}":
    check_command       => 'check_nrpe_1arg!check_flow_control',
    use                 => $nagios_service,
    host_name           => $nagios_alias,
<<<<<<< HEAD
    target              => "/etc/nagios/conf.d/puppet/service_${nagios_alias}.cfg",
=======
    target              => "/etc/nagios3/conf.d/puppet/service_${nagios_alias}.cfg",
>>>>>>> 1e86654231d7c29360426c7db6fb721c0f31061c
    service_description => "${nagios_alias}_check_flow_control",
    tag                 => $monitoring_environment,
  }
}
