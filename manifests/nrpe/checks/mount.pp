# == Class: nagios::nrpe::checks::mount
#
# A simple class, this will deploy the check_mount script to the server and
# permission it correctly. This allows a define to be used as many times as you
# like for the nagios check itself, without any name/ duplicate decleration
# issues.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com>
class nagios::nrpe::checks::mount {
  require nagios::nrpe::config

  file { 'check_mount.sh':
    ensure => present,
    path   => '/usr/lib/nagios/plugins/check_mount.sh',
    source => 'puppet:///modules/nagios/nrpe/checks/check_mount.sh',
    owner  => 'nagios',
    group  => 'nagios',
    mode   => '0755',
  }
}
