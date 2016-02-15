# == Define: nagios::nrpe::mysql::file_privs
#
# This is going to implement the percona mysql file privileges check which
# checks the permissions on mysql files are correct.
#
# Note: This requires the /var/lib/mysql/ to have non standard permissions in
# order for nagios to actually check so it probably isnt actually the best check
# to use.
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
#   submitting a check for a virtual ip.
#
# === Examples
#
#   class { ::nagios::nrpe::mysql::file_privs:
#   }
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com>
class nagios::nrpe::mysql::file_privs (
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $nagios_alias           = $::hostname) {
  require nagios::nrpe::config
  include nagios::nrpe::service
  require nagios::nrpe::mysql::package

  file_line { 'check_file_privs':
    ensure => present,
    line   => 'command[check_file_privs]=/usr/lib64/nagios/plugins/pmp-check-mysql-file-privs',
    path   => '/etc/nagios/nrpe_local.cfg',
    match  => 'command\[check_file_privs\]',
    notify => Service['nrpe'],
  }

  @@nagios_service { "check_file_privs_${nagios_alias}":
    check_command       => 'check_nrpe_1arg!check_file_privs',
    use                 => $nagios_service,
    host_name           => $nagios_alias,
<<<<<<< HEAD
    target              => "/etc/nagios/conf.d/puppet/service_${nagios_alias}.cfg",
=======
    target              => "/etc/nagios3/conf.d/puppet/service_${nagios_alias}.cfg",
>>>>>>> 1e86654231d7c29360426c7db6fb721c0f31061c
    service_description => "${nagios_alias}_check_file_privs",
    tag                 => $monitoring_environment,
  }
}