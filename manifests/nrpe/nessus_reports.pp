# == Class: nagios::nrpe::memory
#
# Uses a script to check the number of high and critical exploits in a nessus report.
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
#   submitting a check for a virtual ip. Not required.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com>
class nagios::nrpe::nessus_reports (
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $nagios_alias           = $::hostname,) {
  require nagios::nrpe::config
  include nagios::nrpe::service

  file { 'check_nessus_reports.sh':
    ensure => present,
    path   => '/usr/lib/nagios/plugins/check_mem.sh',
    source => 'puppet:///modules/nagios/check_mem.sh',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    before => File_line['check_nessus_reports'],
  }

  @@nagios_service { "check_memory_${nagios_alias}":
    check_command       => 'check_nrpe_1arg!check_mem',
    use                 => $nagios_service,
    host_name           => $nagios_alias,
    target              => "/etc/nagios3/conf.d/puppet/service_${nagios_alias}.cfg",
    service_description => "${nagios_alias}_check_memory",
    tag                 => $monitoring_environment,
  }

}