# == Class: nagios::nrpe::memory
#
# Uses a script to check the number of high and critical exploits in a nessus
# report.
#
# === Parameters
#
# [*namevar*]
#   The name of the scan to check.
#   Not required.
#
# [*monitoring_environment*]
#   This is the environment that the check will be submitted for. This will
#   default to the value set by nagios::nrpe::config but can be overridden here.
#   Not required.
#
# [*nagios_service*]
#   This is the generic service that this check will implement. This should
#   be set by nagios::nrpe::config but can be overridden here. 
#   Not required.
#
# [*nagios_alias*]
#   This is the hostname that the check will be submitted for. This should
#   almost always be the hostname, but could be overriden, for instance when
#   submitting a check for a virtual ip. 
#   Not required.
#
# [*credentials_location*]
#   The location for the nessus credentials. 
#   Not required. Defaults to /etc/nagios3/conf.d/puppet/credentials_nessus
#
# [*warning*]
#   The warning level for exploits to alert on 
#   Required.
#
# [*critical*]
#   The critical level for exploits to alert on 
#   Required.
#
# [*nessus_port*]
#   The location for the nessus credentials. 
#   Not required. Defaults to /etc/nagios3/conf.d/puppet/credentials_nessus
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com>
define nagios::nrpe::nessus_reports (
  $scan                   = $name,
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $nagios_alias           = $::hostname,
  $credentials_location   = '/etc/nagios3/conf.d/puppet/credentials_nessus',
  $warning,
  $critical,
  $nessus_port            = '8834') {
  require nagios::nrpe::config
  include nagios::nrpe::service

  @@nagios_service { "check_nessus_reports_${scan}":
    check_command       => "check_nessus_reports!${::fqdn}:${nessus_port}!${credentials_location}!\"${scan}\"!${critical}!${warning}",
    use                 => $nagios_service,
    host_name           => $nagios_alias,
    target              => "/etc/nagios3/conf.d/puppet/service_${nagios_alias}.cfg",
    service_description => "${nagios_alias}_check_nessus_reports_${scan}",
    tag                 => $monitoring_environment,
  }

}