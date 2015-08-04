# == Class: nagios::nrpe::lowmemory
#
# Uses a simple lowmemory check. Will warn if less than 3% lowmemory, critical
# on 1%.
#
# It will deploy the check, add the command and then create the service on the
# nagios server
#
# It will only deploy the check to 32 bit systems as this should not be a
# problem on 64 bit systems.
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
class nagios::nrpe::lowmemory (
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $nagios_alias           = $::hostname,) {
  require nagios::nrpe::config
  include nagios::nrpe::service

  if $::architecture == 'i386' or $::architecture == 'x86' {
    file { 'check_lowmemory.sh':
      ensure => present,
      path   => '/usr/lib/nagios/plugins/check_lowmemory.sh',
      source => 'puppet:///modules/nagios/check_lowmemory.sh',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      before => File_line['check_lowmemory'],
    }

    file_line { 'check_lowmemory':
      ensure => present,
      line   => 'command[check_lowmemory]=/usr/lib/nagios/plugins/check_lowmemory.sh -w 3 -c 1',
      path   => '/etc/nagios/nrpe_local.cfg',
      match  => 'command\[check_lowmemory\]',
      notify => Service['nrpe'],
    }

    @@nagios_service { "check_lowmemory_${nagios_alias}":
      check_command       => 'check_nrpe_1arg!check_lowmemory',
      use                 => 'generic-service-excluding-pagerduty',
      host_name           => $nagios_alias,
      target              => "/etc/nagios3/conf.d/puppet/service_${nagios_alias}.cfg",
      service_description => "${nagios_alias}_check_lowmemory",
      tag                 => $monitoring_environment,
    }

  }

}
