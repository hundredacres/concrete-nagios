# == Class: nagios::nrpe::kernel_leak
#
# Uses a simple kernel leak check. Will warn if less than 3% lowmemory, critical
# on 1% AND will warn if more than 8000000 objects, critical on 10000000
#
# It will deploy the check, add the command and then create the service on the
# nagios server.
#
# It will only deploy the check to 32 bit systems as this should not be a
# problem on 64 bit systems.
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
class nagios::nrpe::kernel_leak (
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $nagios_alias           = $::hostname,) {
  require nagios::nrpe::config
  include nagios::nrpe::service

  if $::architecture == 'i386' or $::architecture == 'x86' {
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

    @@nagios_service { "check_kernel_leak_${nagios_alias}":
      check_command       => 'check_nrpe_1arg!check_kernel_leak',
      use                 => 'generic-service-excluding-pagerduty',
      host_name           => $nagios_alias,
      target              => "/etc/nagios3/conf.d/puppet/service_${nagios_alias}.cfg",
      service_description => "${nagios_alias}_check_kernel_leak",
      tag                 => $monitoring_environment,
    }

    @motd::register { 'Nagios Kernel Leak Check': }
  }
}
