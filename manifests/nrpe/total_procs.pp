# == Class: nagios::nrpe::total_procs
#
# This manifest will configure a check on total processes and remove the default
# one. I am of the opinion that a static check like this is almost completly
# pointless, and to be of any use it should focus on crossing moving averages or
# something similar, so the static line is set arbitrarily high.
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
class nagios::nrpe::total_procs {
  require nagios::nrpe::config
  include nagios::nrpe::service
  include nagios::params

  $nagios_service = $::nagios::params::nagios_service

  @@nagios_service { "check_total_procs_${::hostname}":
    check_command       => 'check_nrpe_1arg!check_total_procs',
    use                 => $nagios_service,
    host_name           => $::hostname,
    target              => "/etc/nagios3/conf.d/puppet/service_${::fqdn}.cfg",
    service_description => "${::hostname}_check_total_procs",
    tag                 => $::environment,
  }

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

  @motd::register { 'Nagios Total Processes Check': }

}
