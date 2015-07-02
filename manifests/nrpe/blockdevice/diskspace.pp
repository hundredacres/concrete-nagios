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
#   -Critical = 5%
# *Disk Size  > 1024GB:
#   -Warning  = 4%
#   -Critical = 2%
#
# Note: It will set the name of the check to reference sysvol not xvda for
# cleanness in the nagios server
#
# === Parameters
#
# [*namevar*]
#   This will provide the drive reference (ie xvda from xen machines).
#
# === Variables
#
# [*nagios_service*]
#   This is the generic service it will implement. This is set from
#   nagios::params. This should be set by heira in the future.
#
# [*size*]
#   This is the size in bytes of the drive. This is will call the fact
#   $::blockdevice_${namevar}_size in order to find this.
#
# [*warning*]
#   The % of the diskspace to trigger the warning level at. This is calculated
#   by the above table, with a potential override from $override_warning.
#
# [*warning*]
#   The % of the diskspace to trigger the warning level at. This is calculated
#   by the above table, with a potential override from $override_warning.
#
# [*critical*]
#   The % of the diskspace to trigger the critical level at. This is calculated
#   by the above table, with a potential override from $override_warning.
#
# [*override_warning*]
#   This will override the warning level using the ::diskspace_namevar_warning.
#   This should be an integer value defined in the ENC.
#
# [*override_warning*]
#   This will override the critical level using the
#   ::diskspace_namevar_critical.
#   This should be an integer value defined in the ENC.
#
# === Examples
#
#   nagios::nrpe::blockdevice::diskspace { 'xvda':
#   }
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com
define nagios::nrpe::blockdevice::diskspace (
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $nagios_alias           = $::hostname) {
  # This has to use a getvar method to return a fact containing another
  # variable in the name.
  $size = getvar("::blockdevice_${name}_size")

  # This has to use a getvar method to return a fact containing another
  # variable in the name. The fact will be defined through the ENC.
  $override_warning = getvar("::diskspace_${name}_warning")

  # This has to use a getvar method to return a fact containing another
  # variable in the name. The fact will be defined through the ENC.
  $override_critical = getvar("::diskspace_${name}_critical")

  if ($override_warning == '' or $override_warning == nil or $override_warning 
  == undef) {
    # Going to have a different check for very large disks ( gt 100GB) and
    # huge disks (gt 1TB)
    if $size > 15 * 1024 * 1024 * 1024 * 1024 {
      # greater than 15TB
      $warning = '10'
    } elsif $size > 1024 * 1024 * 1024 * 1024 {
      # greater than 1TB
      $warning = '15'
    } elsif $size > 100 * 1024 * 1024 * 1024 {
      # greater than 100GB
      $warning = '18'
    } else {
      $warning = '20'
    }
  } else {
    $warning = $override_warning
  }

  if ($override_critical == '' or $override_critical == nil or 
  $override_critical == undef) {
    # Going to have a different check for very large disks ( gt 100GB) and
    # huge disks (gt 1TB)
    if $size > 15 * 1024 * 1024 * 1024 * 1024 {
      # greater than 15TB
      $critical = '5'
    } elsif $size > 1024 * 1024 * 1024 * 1024 {
      # greater than 1TB
      $critical = '8'
    } elsif $size > 100 * 1024 * 1024 * 1024 {
      # greater than 100GB
      $critical = '8'
    } else {
      $critical = '10'
    }
  } else {
    $critical = $override_critical
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

  @@nagios_service { "check_${drive}_space_${nagios_alias}":
    check_command       => "check_nrpe_1arg!check_${name}_diskspace",
    use                 => $nagios_service,
    host_name           => $nagios_alias,
    target              => "/etc/nagios3/conf.d/puppet/service_${::fqdn}.cfg",
    service_description => "${nagios_alias}_check_${drive}_space",
    tag                 => $monitoring_environment,
  }

  @motd::register { "Nagios Diskspace Check ${name}": }

}
