# == Class: nagios::nrpe::pacemaker
#
# This is going to check that all members are correctly connected to the
# pacemaker cluster. This uses a built in feature in pacemaker that provides
# nagios compatible monitoring. This is fully compatible with heartbeat and
# corosync. This will require sudo and so will add the nagios user to the
# sudoers file for this specific command.
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
class nagios::nrpe::pacemaker (
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $alias                  = $::hostname,) {
  require nagios::nrpe::config
  include nagios::nrpe::service

  file_line { 'pacemaker_sudoers':
    ensure => present,
    line   => 'nagios ALL=(ALL) NOPASSWD: /usr/sbin/crm_mon -s',
    path   => '/etc/sudoers',
    before => File_line['check_pacemaker'],
  }

  file_line { 'check_pacemaker':
    ensure => present,
    line   => 'command[check_pacemaker]=/usr/bin/sudo /usr/sbin/crm_mon -s',
    path   => '/etc/nagios/nrpe_local.cfg',
    match  => 'command\[check_pacemaker\]',
    notify => Service['nrpe'],
  }

  @@nagios_service { "check_pacemaker_${alias}":
    check_command       => 'check_nrpe_1arg!check_pacemaker',
    use                 => $nagios_service,
    host_name           => $alias,
    target              => "/etc/nagios3/conf.d/puppet/service_${::fqdn}.cfg",
    service_description => "${alias}_check_pacemaker",
    tag                 => $monitoring_environment,
  }

  @motd::register { 'Nagios Pacemaker Check': }

}
