# == Class: nagios::nrpe::zombie_procs
#
# This manifest will configure a check on zombie processes. It uses the default
# one, which seems to be at a reasonable level.
#
# === Variables
#
# [*nagios_service*]
#   This is the generic service it will implement. This is set from
#   nagios::params. This should be set by heira in the future.
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
    target              => "/etc/nagios3/conf.d/puppet/service_${::fqdn}.cfg",
    service_description => "${nagios_alias}_check_zombie_procs",
    tag                 => $monitoring_environment,
  }

  @motd::register { 'Nagios Zombie Processes Check': }

}

