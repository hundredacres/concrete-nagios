# == Class: nagios::nrpe::lowmemory
#
# Uses a simple lowmemory check. Will warn if less than 3% lowmemory, critical
# on 1%.
#
# It will deploy the check, add the command and then create the service on the
# nagios server
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
class nagios::nrpe::lowmemory (
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $alias                  = $::hostname,) {
  require nagios::nrpe::config
  include nagios::nrpe::service

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

  @@nagios_service { "check_lowmemory_${alias}":
    check_command       => 'check_nrpe_1arg!check_lowmemory',
    use                 => 'generic-service-excluding-pagerduty',
    host_name           => $alias,
    target              => "/etc/nagios3/conf.d/puppet/service_${::fqdn}.cfg",
    service_description => "${alias}_check_lowmemory",
    tag                 => $monitoring_environment,
  }

  @motd::register { 'Nagios Lowmemory Check': }

}
