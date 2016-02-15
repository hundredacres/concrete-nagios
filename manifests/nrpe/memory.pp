# == Class: nagios::nrpe::memory
#
# Uses a simple check mem script from nagios exchange (could potentially do with
# cleaning up). Will warn if less than 15% memory, critical on 5%.
#
# It will deploy the check, add the command and then create the service on the
# nagios server
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
class nagios::nrpe::memory (
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $nagios_alias           = $::hostname,) {
  require nagios::nrpe::config
  include nagios::nrpe::service

  file { 'check_mem.sh':
    ensure => present,
    path   => '/usr/lib/nagios/plugins/check_mem.sh',
    source => 'puppet:///modules/nagios/nrpe/check_mem.sh',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    before => File_line['check_mem'],
  }

  file_line { 'check_mem':
    ensure => present,
    line   => 'command[check_mem]=/usr/lib/nagios/plugins/check_mem.sh -w 85 -c 95',
    path   => '/etc/nagios/nrpe_local.cfg',
    match  => 'command\[check_mem\]',
    notify => Service['nrpe'],
  }

  @@nagios_service { "check_memory_${nagios_alias}":
    check_command       => 'check_nrpe_1arg!check_mem',
    use                 => $nagios_service,
    host_name           => $nagios_alias,
    target              => "/etc/nagios/conf.d/puppet/service_${nagios_alias}.cfg",
    service_description => "${nagios_alias}_check_memory",
    tag                 => $monitoring_environment,
  }

}
