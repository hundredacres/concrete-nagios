# == Define: nagios::nrpe::blockdevice::diskspace
#
# This will take a drive reference as the name, and use it to create a diskspace
# check. It will also look up the size of the drive to determine the
# warning/critical thresholds as follows:
#
# *Disk Size  < 100GB:
#   -Warning  = 20%
#   -Critical = 10%
# *Disk Size  > 100GB:
#   -Warning  = 10%
#   -Critical = 5%#
#
# Note: It will set the name of the check to reference sysvol not xvda for
# cleanness in the nagios server
#
# === Parameters
#
# [*namevar*]
#   This will provide the drive reference (ie xvda from xen machines). Note:
#   this will ignore xvdd and sr0 as these are names for cd drives by default
#   and could cause errors
#
# === Variables
#
# [*nagios_service*]
#   This is the generic service it will implement. This is set from
#   nagios::params. This should be set by heira in the future.
#
# === Examples
#
#   nagios::nrpe::blockdevice::diskspace { 'xvda':
#   }
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com
define nagios::nrpe::blockdevice::diskspace {
  include nagios::params

  $nagios_service = $::nagios::params::nagios_service

  if $name != 'xvdd' and $name != 'sr0' {
    # This has to use a getvar method to return a fact containing another
    # variable in the name.
    $size = getvar("blockdevice_${name}_size")

    # Going to have a different check for very large disks ( gt than 100GB)
    if $size > 100 * 1024 * 1024 * 1024 {
      $warning = '10'
      $critical = '5'
    } else {
      $warning = '20'
      $critical = '10'
    }

    file_line { "check_${name}_diskspace":
      ensure => present,
      line   => "command[check_${name}_diskspace]=/usr/lib/nagios/plugins/check_disk -E -w ${warning}% -c ${critical}% -R /dev/${name}*",
      path   => '/etc/nagios/nrpe_local.cfg',
      match  => "command\[check_${name}_diskspace\]",
      notify => Service['nrpe'],
    }

    # For neatness in nagios interface:
    if $name == 'xvda' {
      $drive = 'sysvol'
    } else {
      $drive = $name
    }

    @@nagios_service { "check_${drive}_space_${::hostname}":
      check_command       => "check_nrpe_1arg!check_${name}_diskspace",
      use                 => $nagios_service,
      host_name           => $::hostname,
      target              => "/etc/nagios3/conf.d/puppet/service_${::fqdn}.cfg",
      service_description => "${::hostname}_check_${drive}_space",
      tag                 => $::environment,
    }

    @motd::register { "Nagios Diskspace Check ${name}": }

  }

}