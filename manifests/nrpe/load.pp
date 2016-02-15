# == Class: nagios::nrpe::load
#
# This manifest will configure a load check, using the built in nagios load
# check. It will use fairly liberal levels:
#
# *Defacto disabled for 1 minute average
# *warning - 90% of available schedule, 5 minute average. critical - 100% of
# available schedule, 5 minute average
# *warning - 80% of available schedule, 15 minute average. critical - 90% of
# available schedule, 15 minute average
#
# However this will still give false postives in 2 situations:
#
# High iowait/network wait. This should be alleviated by io check.
# Short running batch jobs. This is a limitation of load as a metric.
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
# [*warning_threshold_1*]
#   The warning threshold for the 1 minute load.
#   Not Required. Defaults to 90 (defacto disabled).
#
# [*warning_threshold_5*]
#   The warning threshold for the 5 minute load.
#   Not Required. Defaults to 0.9
#
# [*warning_threshold_15*]
#   The warning threshold for the 15 minute load.
#   Not Required. Defaults to 0.8
#
# [*critical_threshold_1*]
#   The critical threshold for the 1 minute load.
#   Not Required. Defaults to 100 (defacto disabled).
#
# [*critical_threshold_5*]
#   The critical threshold for the 5 minute load.
#   Not Required. Defaults to 1
#
# [*critical_threshold_15*]
#   The critical threshold for the 15 minute load.
#   Not Required. Defaults to 0.9
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com>
class nagios::nrpe::load (
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $nagios_alias           = $::hostname,
  $warning_threshold_1 = 90,
  $warning_threshold_5 = 0.9,
  $warning_threshold_15 = 0.8,
  $critical_threshold_1 = 100,
  $critical_threshold_5 = 1,
  $critical_threshold_15 = 0.9) {
  require nagios::nrpe::config
  include nagios::nrpe::service

  # Fully dynamic load check:

  $loadwarning1 = $::processorcount * $warning_threshold_1
  $loadwarning5 = $::processorcount * $warning_threshold_5
  $loadwarning15 = $::processorcount * $warning_threshold_15
  $loadcritical1 = $::processorcount * $critical_threshold_1
  $loadcritical5 = $::processorcount * $critical_threshold_5
  $loadcritical15 = $::processorcount * $critical_threshold_15

  $check = "command[check_load]=/usr/lib/nagios/plugins/check_load -w ${loadwarning1},${loadwarning5},${loadwarning15} -c ${loadcritical1},${loadcritical5},${loadcritical15}"

  file_line { 'check_load':
    ensure => present,
    line   => $check,
    path   => '/etc/nagios/nrpe_local.cfg',
    match  => 'command\[check_load\]',
    notify => Service['nrpe'],
    before => File_line['check_load_default'],
  }

  file_line { 'check_load_default':
    ensure => absent,
    line   => 'command[check_load]=/usr/lib/nagios/plugins/check_load -w 15,10,5 -c 30,25,20',
    path   => '/etc/nagios/nrpe.cfg',
    match  => 'command\[check_load\]',
    notify => Service['nrpe'],
  }

  @@nagios_service { "check_load_${nagios_alias}":
    check_command       => 'check_nrpe_1arg!check_load',
    use                 => $nagios_service,
    host_name           => $nagios_alias,
    target              => "/etc/nagios/conf.d/puppet/service_${nagios_alias}.cfg",
    service_description => "${nagios_alias}_check_load",
    tag                 => $monitoring_environment,
  }

}

