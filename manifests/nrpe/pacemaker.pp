# == Class: nagios::nrpe::pacemaker
#
# This is going to check that all members are correctly connected to the
# pacemaker cluster. This uses a built in feature in pacemaker that provides
# nagios compatible monitoring. This is fully compatible with heartbeat and
# corosync. This will require sudo and so will add the nagios user to the
# sudoers file for this specific command.
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
# Ben Field <ben.field@concreteplatform.com
class nagios::nrpe::pacemaker (
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $nagios_alias           = $::hostname,) {
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

  @@nagios_service { "check_pacemaker_${nagios_alias}":
    check_command       => 'check_nrpe_1arg!check_pacemaker',
    use                 => $nagios_service,
    host_name           => $nagios_alias,
<<<<<<< HEAD
    target              => "/etc/nagios/conf.d/puppet/service_${nagios_alias}.cfg",
=======
    target              => "/etc/nagios3/conf.d/puppet/service_${nagios_alias}.cfg",
>>>>>>> 1e86654231d7c29360426c7db6fb721c0f31061c
    service_description => "${nagios_alias}_check_pacemaker",
    tag                 => $monitoring_environment,
  }

}
