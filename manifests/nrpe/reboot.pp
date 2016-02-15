# == Class: nagios::nrpe::reboot
#
# Checks if a host needs to be rebooted as a result of updates.  The script
# checks for /var/run/reboot-required and raises a warning if present. It never
# raises a critical in order to minimise unnecessary emails etc.
#
# === Variables
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
# Justin Miller <justin.miller@concreteplatform.com>
class nagios::nrpe::reboot (
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $nagios_alias           = $::hostname,) {
  require nagios::nrpe::config
  include nagios::nrpe::service

  file { 'check_reboot.sh':
    ensure => present,
    path   => '/usr/lib/nagios/plugins/check_reboot.sh',
    source => 'puppet:///modules/nagios/nrpe/check_reboot.sh',
    owner  => 'nagios',
    group  => 'nagios',
    mode   => '0755',
    before => File_line['check_reboot'],
  }

  file_line { 'check_reboot':
    ensure => present,
    line   => 'command[check_reboot]=/usr/lib/nagios/plugins/check_reboot.sh',
    path   => '/etc/nagios/nrpe_local.cfg',
    match  => 'command\[check_reboot\]',
    notify => Service[nrpe],
  }

  @@nagios_service { "check_reboot_${nagios_alias}":
    check_command       => 'check_nrpe_1arg!check_reboot',
    use                 => $nagios_service,
    host_name           => $nagios_alias,
    target              => "/etc/nagios/conf.d/puppet/service_${nagios_alias}.cfg",
    service_description => "${nagios_alias}_check_reboot",
    tag                 => $monitoring_environment,
  }

}
