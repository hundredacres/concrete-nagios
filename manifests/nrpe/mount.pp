# == Class: nagios::nrpe::mount
#
# This will deploy a mount check that will check that the mount is valid and
# working correctly. If it isnt, the check will timeout.
#
# === Parameters
#
# [*namevar*]
#   The location that the check will test. This will default to the default to
#   the define name.
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
define nagios::nrpe::mount (
  $mount_path             = $name,
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $nagios_alias           = $::hostname,) {
  require nagios::nrpe::config
  include nagios::nrpe::service
  require nagios::nrpe::checks::mount

  file_line { "check_mount_${mount_path}":
    ensure => present,
    line   => "command[check_mount_${mount_path}]=/usr/lib/nagios/plugins/check_mount.sh -p ${mount_path}",
    path   => '/etc/nagios/nrpe_local.cfg',
    match  => "command\[check_mount_${mount_path}\]",
    notify => Service[nrpe],
  }

  @@nagios_service { "check_mount_${mount_path}_on_${nagios_alias}":
    check_command       => "check_nrpe_1arg!check_mount_${mount_path}",
    use                 => $nagios_service,
    host_name           => $nagios_alias,
<<<<<<< HEAD
    target              => "/etc/nagios/conf.d/puppet/service_${nagios_alias}.cfg",
=======
    target              => "/etc/nagios3/conf.d/puppet/service_${nagios_alias}.cfg",
>>>>>>> 1e86654231d7c29360426c7db6fb721c0f31061c
    service_description => "${nagios_alias}_check_mount_${mount_path}",
    tag                 => $monitoring_environment,
  }

}
