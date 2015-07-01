# == Class: nagios::nrpe::inodes
#
# A wrapper class that will break up the fact $::used_blockdevices into its
# constituent parts and pass it to the inodes check
# nagios::nrpe::blockdevice::diskspace. It also has one extra - and an extra
# section that tests for lvm usage and adds checks for these.
#
# It would be sensible in the future to combine this with iostat and diskspace
# into a single blockdevice check, but all have exceptional sections that would
# be then branched out.
#
# === Variables
#
# [*nagios_service*]
#   This is the generic service it will implement. This is set from
#   nagios::params. This should be set by heira in the future.
#
# [*drive*]
#   This is an array built from the blockdevices fact. It should be an array of
#   all the drives.
#
# [*excludedDrives*]
#   A string of all the drives with -I prepended. ie "-I xvda -I xvdb". This is
#   then used to generate a space check for the lvm spaces. There may be a
#   better way of including LVM drives rather than excluding them.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com
class nagios::nrpe::inodes (
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $alias                  = $::hostname,) {
  require nagios::nrpe::config
  include nagios::nrpe::service

  $drive = split($::used_blockdevices, ',')

  nagios::nrpe::blockdevice::inodes { $drive:
    monitoring_environment => $monitoring_environment,
    nagios_service         => $nagios_service,
    alias                  => $alias,
  }

  if $::lvm == true {
    $excludedDrives = join(prefix($drive, '-I '), ' ')

    file_line { 'check_LVM_inodes':
      ensure => present,
      line   => "command[check_LVM_inodes]=/usr/lib/nagios/plugins/check_disk -W 15% -K 5% -p / ${excludedDrives}",
      path   => '/etc/nagios/nrpe_local.cfg',
      match  => 'command\[check_LVM_inodes\]',
      notify => Service['nrpe'],
    }

    @@nagios_service { "check_LVM_inodes_${alias}":
      check_command       => 'check_nrpe_1arg!check_LVM_inodes',
      use                 => $nagios_service,
      host_name           => $alias,
      target              => "/etc/nagios3/conf.d/puppet/service_${::fqdn}.cfg",
      service_description => "${alias}_check_LVM_inodes",
      tag                 => $monitoring_environment,
    }

    @motd::register { 'Nagios Inodes Check LVM': }
  }

}
