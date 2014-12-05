# == Class: nagios::nrpe::inodes
#
# A wrapper class that will break up the fact $::blockdevices into its constituent parts and pass it to the inodes
# check nagios::nrpe::blockdevice::diskspace. It also has one extra - and an extra section that tests for lvm usage and
# adds checks for these.
#
# It would be sensible in the future to combine this with iostat and diskspace into a single blockdevice check, but all
# have exceptional sections that would be then branched out.
#
# === Variables
#
# [*nagios_service*]
#   This is the generic service it will implement. This is set from nagios::params. This should be set by heira in the
#   future.
#
# [*drive*]
#   This is an array built from the blockdevices fact. It should be an array of all the drives.
#
# [*excludedDrives*]
#   A string of all the drives with -I prepended. ie "-I xvda -I xvdb". This is then used to generate a space check for
#   the lvm spaces. There may be a better way of including LVM drives rather than excluding them.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com
class nagios::nrpe::inodes {
  require nagios::nrpe::config
  include nagios::nrpe::service
  include nagios::params

  $nagios_service = $::nagios::params::nagios_service

  $drive = split($::blockdevices, ',')

  nagios::nrpe::blockdevice::inodes { $drive: }

  if $::lvm == 'true' {
    $excludedDrives = join(prefix($drive, '-I '), ' ')

    file_line { 'check_LVM_inodes':
      ensure => present,
      line   => "command[check_LVM_inodes]=/usr/lib/nagios/plugins/check_disk -W 15% -K 5% -p / ${excludedDrives}",
      path   => '/etc/nagios/nrpe_local.cfg',
      match  => "command\[check_LVM_inodes\]",
      notify => Service['nrpe'],
    }

    @@nagios_service { "check_LVM_inodes_${::hostname}":
      check_command       => 'check_nrpe_1arg!check_LVM_inodes',
      use                 => $nagios_service,
      host_name           => $::hostname,
      target              => "/etc/nagios3/conf.d/puppet/service_${::fqdn}.cfg",
      service_description => "${::hostname}_check_LVM_inodes",
      tag                 => $::environment,
    }

    @motd::register { 'Nagios Inodes Check LVM': }
  }

}
