# == Class: nagios::nrpe::reboot
#
# Checks if a host needs to be rebooted as a result of updates.  The script
# checks for /var/run/reboot-required and raises a warning if present. It never
# raises a critical in order to minimise unnecessary emails etc.
#
# === Variables
#
# [*nagios_service*]
#   This is the generic service it will implement. This is set from
#   nagios::params. This should be set by heira in the future.
#
# === Authors
#
# Justin Miller <justin.miller@concreteplatform.com
class nagios::nrpe::reboot (
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $alias                  = $::hostname,) {
  require nagios::nrpe::config
  include nagios::nrpe::service

  file { 'check_reboot.sh':
    ensure => present,
    path   => '/usr/lib/nagios/plugins/check_reboot.sh',
    source => 'puppet:///modules/nagios/check_reboot.sh',
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

  @@nagios_service { "check_reboot_${alias}":
    check_command         => 'check_nrpe_1arg!check_reboot',
    use                   => $nagios_service,
    host_name             => $alias,
    target                => "/etc/nagios3/conf.d/puppet/service_${::fqdn}.cfg",
    service_description   => "${alias}_check_reboot",
    tag                   => $monitoring_environment,
    notifications_enabled => 0,
  }

  @motd::register { 'Nagios Reboot Check': }

}
