# == Class: nagios::nrpe::zombie_procs
#
# This manifest will configure a check on zombie processes. It uses the default
# one, which seems to be at a reasonable level.
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
class nagios::nrpe::zombie_procs (
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $nagios_alias           = $::hostname,) {
  require nagios::nrpe::config
  include nagios::nrpe::service

  @@nagios_service { "check_zombie_procs_${nagios_alias}":
    check_command       => 'check_nrpe_1arg!check_zombie_procs',
    use                 => $nagios_service,
    host_name           => $nagios_alias,
<<<<<<< HEAD
    target              => "/etc/nagios/conf.d/puppet/service_${nagios_alias}.cfg",
=======
    target              => "/etc/nagios3/conf.d/puppet/service_${nagios_alias}.cfg",
>>>>>>> 1e86654231d7c29360426c7db6fb721c0f31061c
    service_description => "${nagios_alias}_check_zombie_procs",
    tag                 => $monitoring_environment,
  }
}