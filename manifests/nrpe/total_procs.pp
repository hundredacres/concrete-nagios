# == Class: nagios::nrpe::total_procs
#
# This manifest will configure a check on total processes and remove the default
# one. I am of the opinion that a static check like this is almost completly
# pointless, and to be of any use it should focus on crossing moving averages or
# something similar, so the static line is set arbitrarily high.
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
# Ben Field <ben.field@concreteplatform.com
class nagios::nrpe::total_procs (
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $nagios_alias           = $::hostname,) {
  require nagios::nrpe::config
  include nagios::nrpe::service

  file_line { 'check_total_procs_default':
    ensure => absent,
    line   => 'command[check_total_procs]=/usr/lib/nagios/plugins/check_procs -w 150 -c 200',
    path   => '/etc/nagios/nrpe.cfg',
    match  => 'command\[check_total_procs\]',
    notify => Service['nrpe'],
  }

  file_line { 'check_total_procs':
    ensure => present,
    line   => 'command[check_total_procs]=/usr/lib/nagios/plugins/check_procs -w 500 -c 600',
    path   => '/etc/nagios/nrpe_local.cfg',
    match  => 'command\[check_total_procs\]',
    notify => Service['nrpe'],
  }

  @@nagios_service { "check_total_procs_${nagios_alias}":
    check_command       => 'check_nrpe_1arg!check_total_procs',
    use                 => $nagios_service,
    host_name           => $nagios_alias,
<<<<<<< HEAD
    target              => "/etc/nagios/conf.d/puppet/service_${nagios_alias}.cfg",
=======
    target              => "/etc/nagios3/conf.d/puppet/service_${nagios_alias}.cfg",
>>>>>>> 1e86654231d7c29360426c7db6fb721c0f31061c
    service_description => "${nagios_alias}_check_total_procs",
    tag                 => $monitoring_environment,
  }

}
