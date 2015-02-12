# == Class: nagios::nrpe::kernel_leak
#
# Uses a simple kernel leak check. Will warn if less than 3% lowmemory, critical
# on 1% AND will warn if more than 8000000 objects, critical on 10000000
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
class nagios::nrpe::kernel_leak {
  require nagios::nrpe::config
  include nagios::nrpe::service
  include nagios::params

  $nagios_service = $::nagios::params::nagios_service
  
  include basic_server::params

  $monitoring_environment = $::basic_server::params::monitoring_environment

  file { 'check_kernel_leak.sh':
    ensure => present,
    path   => '/usr/lib/nagios/plugins/check_kernel_leak.sh',
    source => 'puppet:///modules/nagios/check_kernel_leak.sh',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    before => File_line['check_kernel_leak'],
  }

  file_line { 'slabinfo_sudoers':
    ensure => present,
    line   => 'nagios ALL=(ALL) NOPASSWD: /bin/cat /proc/slabinfo',
    path   => '/etc/sudoers',
    before => File_line['check_kernel_leak'],
  }

  file_line { 'check_kernel_leak':
    ensure => present,
    line   => 'command[check_kernel_leak]=/usr/lib/nagios/plugins/check_kernel_leak.sh -w 2,8000000,3 -c 1,10000000,4',
    path   => '/etc/nagios/nrpe_local.cfg',
    match  => 'command\[check_kernel_leak\]',
    notify => Service['nrpe'],
  }

  @@nagios_service { "check_kernel_leak_${::hostname}":
    check_command       => 'check_nrpe_1arg!check_kernel_leak',
    use                 => 'generic-service-excluding-pagerduty',
    host_name           => $::hostname,
    target              => "/etc/nagios3/conf.d/puppet/service_${::fqdn}.cfg",
    service_description => "${::hostname}_check_kernel_leak",
    tag                 => $monitoring_environment,
  }

  @motd::register { 'Nagios Kernel Leak Check': }

}
