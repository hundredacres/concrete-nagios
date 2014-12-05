# == Class: nagios::nrpe::load
#
# This manifest will configure a load check, using the built in nagios load check. It will use fairly liberal levels:
#
# warning - 90% of available schedule, 1 minute average. critical - 100% of available schedule, 1 minute average
# warning - 80% of available schedule, 5 minute average. critical - 90% of available schedule, 5 minute average
# warning - 70% of available schedule, 15 minute average. critical - 80% of available schedule, 15 minute average
#
# However this will still give false postives in 2 situations:
#
# High iowait/network wait. This should be alleviated by io check.
# Short running batch jobs. This is a limitation of load as a metric.
#
# === Variables
#
# [*nagios_service*]
#   This is the generic service it will implement. This is set from nagios::params. This should be set by heira in the
#   future.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com
class nagios::nrpe::load {
  require nagios::nrpe::config
  include nagios::nrpe::service
  include nagios::params

  $nagios_service = $::nagios::params::nagios_service

  # Fully dynamic load check:

  $loadwarning1 = $::processorcount * 0.9
  $loadwarning5 = $::processorcount * 0.8
  $loadwarning15 = $::processorcount * 0.7
  $loadcritical1 = $::processorcount * 1
  $loadcritical5 = $::processorcount * 0.9
  $loadcritical15 = $::processorcount * 0.8

  $check = "command[check_load]=/usr/lib/nagios/plugins/check_load -w ${loadwarning1},${loadwarning5},${loadwarning15} -c ${loadcritical1},${loadcritical5},${loadcritical15}"

  file_line { "check_load":
    ensure => present,
    line   => $check,
    path   => "/etc/nagios/nrpe_local.cfg",
    match  => "command\[check_load\]",
    notify => Service[nrpe],
    before => File_line[check_load_default],
  }

  file_line { "check_load_default":
    ensure => absent,
    line   => "command[check_load]=/usr/lib/nagios/plugins/check_load -w 15,10,5 -c 30,25,20",
    path   => "/etc/nagios/nrpe.cfg",
    match  => "command\[check_load\]",
    notify => Service[nrpe],
  }

  @@nagios_service { "check_load_${hostname}":
    check_command       => "check_nrpe_1arg!check_load",
    use                 => "${nagios_service}",
    host_name           => $hostname,
    target              => "/etc/nagios3/conf.d/puppet/service_${fqdn}.cfg",
    service_description => "${hostname}_check_load",
    tag                 => "${environment}",
  }

  @motd::register { 'Nagios CPU Load Check': }

}

