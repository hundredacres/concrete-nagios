# == Define: nagios::nrpe::mysql::replication_delay
#
# This is going to implement the percona mysql replication delay check which is
# used to check the delay in master slave replication.
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
#   class { ::nagios::nrpe::mysql::replication_delay :
#   }
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com>
class nagios::nrpe::mysql::replication_delay (
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $nagios_alias           = $::hostname) {
  require nagios::nrpe::config
  include nagios::nrpe::service
  require nagios::nrpe::mysql::package

  file_line { 'check_replication_delay':
    ensure => present,
    line   => 'command[check_replication_delay]=/usr/lib64/nagios/plugins/pmp-check-mysql-replication-delay -w 60 -c 300',
    path   => '/etc/nagios/nrpe_local.cfg',
    match  => 'command\[check_replication_delay\]',
    notify => Service['nrpe'],
  }

  @@nagios_service { "check_replication_delay_${nagios_alias}":
    check_command       => 'check_nrpe_1arg!check_replication_delay',
    use                 => $nagios_service,
    host_name           => $nagios_alias,
    target              => "/etc/nagios3/conf.d/puppet/service_${nagios_alias}.cfg",
    service_description => "${nagios_alias}_check_replication_delay",
    tag                 => $monitoring_environment,
  }
}
