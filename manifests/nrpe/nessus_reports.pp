# == Class: nagios::nrpe::memory
#
# Uses a script to check the number of high and critical exploits in a nessus
# report.
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
define nagios::nrpe::nessus_reports (
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $nagios_alias           = $::hostname,
  $credentials_location,
  $warning,
  $critical,
  $scan,
  $nessus_port            = '8834') {
  require nagios::nrpe::config
  include nagios::nrpe::service

  @@nagios_service { "check_nessus_reports_${scan}":
    check_command       => "check_nessus_reports!${::fqdn}:${nessus_port}!${credentials_file}!\"${scan}\"!${critical}!${warning}",
    use                 => $nagios_service,
    host_name           => $nagios_alias,
    target              => "/etc/nagios3/conf.d/puppet/service_${nagios_alias}.cfg",
    service_description => "${nagios_alias}_check_memory",
    tag                 => $monitoring_environment,
  }

}