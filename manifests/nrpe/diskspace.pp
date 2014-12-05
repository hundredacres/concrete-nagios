# == Class: nagios::nrpe::diskspace
#
# A wrapper class that will break up the fact $::blockdevices into its constituent parts and pass it to the diskspace
# check nagios::nrpe::blockdevice::diskspace. It also has two extra bits - It removes the default check_disk check which
# would otherwise confuse nrpe, and an extra section that tests for lvm usage and adds checks for these.
#
# It would be sensible in the future to combine this with iostat and inodes into a single blockdevice check, but all
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
class nagios::nrpe::diskspace {
  require nagios::nrpe::config
  include nagios::nrpe::service
  include nagios::params

  $nagios_service = $::nagios::params::nagios_service

  # Remove the default check_disk

  file_line { 'check_disk_default':
    ensure => absent,
    line   => 'command[check_disk]=/usr/lib/nagios/plugins/check_disk -w 20% -c 10% -p /',
    path   => '/etc/nagios/nrpe.cfg',
    match  => 'command\[check_disk\]',
    notify => Service[nrpe],
  }

  $drive = split($::blockdevices, ',')

  nagios::nrpe::blockdevice::diskspace { $drive: require => File_Line['check_disk_default'], }

  if $::lvm == true {
    $excludedDrives = join(prefix($drive, '-I '), ' ')

    file_line { 'check_LVM_diskspace':
      ensure => present,
      line   => "command[check_LVM_diskspace]=/usr/lib/nagios/plugins/check_disk -w 20% -c 10% -p / ${excludedDrives}",
      path   => '/etc/nagios/nrpe_local.cfg',
      match  => 'command\[check_LVM_diskspace\]',
      notify => Service['nrpe'],
    }

    @@nagios_service { "check_LVM_space_${::hostname}":
      check_command       => 'check_nrpe_1arg!check_LVM_diskspace',
      use                 => $nagios_service,
      host_name           => $::hostname,
      target              => "/etc/nagios3/conf.d/puppet/service_${::fqdn}.cfg",
      service_description => "${::hostname}_check_LVM_space",
      tag                 => $::environment,
    }

    @motd::register { 'Nagios Diskspace Check LVM': }
  }
}

