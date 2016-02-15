# == Class: nagios::nrpe::iostat
#
# A wrapper class that will break up the fact $::used_blockdevices into its
# constituent parts and pass it to the iostat check
# nagios::nrpe::blockdevice::iostat. It also has one extra bit - an extra
# section that tests for lvm usage and adds checks for these.
#
# It would be sensible in the future to combine this with diskspace and inodes
# into a single blockdevice check, but all have exceptional sections that would
# be then branched out.
#
# It also has a slightly complicated section that generates a service group per
# xen host on the nagios server. This requires server logic (and some
# interesting logic here) to ensure that it does not try and create a single
# service group multiple times. This requires the nagios::server::iostat class.
#
# It will also make sure load not also trigger if this has triggered, and so
# requires nagios::nrpe::load.
#
# === Parameters
#
# [*monitoring_environment*]
#   This is the environment that the check will be submitted for. This will
#   default to the value set by nagios::nrpe::config but can be overridden here.
#   Not required. This will override the value for the define that it
#   implements.
#
# [*nagios_service*]
#   This is the generic service that this check will implement. This should
#   be set by nagios::nrpe::config but can be overridden here. Not required.
#   This will override the value for the define that it implements.
#
# [*nagios_alias*]
#   This is the hostname that the check will be submitted for. This should
#   almost always be the hostname, but could be overriden, for instance when
#   submitting a check for a virtual ip. Not required. This will override the
#   value for the define that it implements.
#
# [*warning_io_wait*]
#   The warning level for average io wait time. This should average read and
#   writes.
#   Not required. Defaults to '1000'
#
# [*warning_read_wait*]
#   The warning level for average read wait time.
#   Not required. Defaults to '100'
#
# [*warning_write_wait*]
#   The warning level for average write wait time.
#   Not required. Defaults to '200'
#
# [*warning_service_wait*]
#   The warning level for average service wait time.
#   Not required. Defaults to '100'
#
# [*warning_cpu_util*]
#   The warning level for average cpu utilisation
#   Not required. Defaults to '100'
#
# [*critical_io_wait*]
#   The critical level for average io wait time. This should average read and
#   writes.
#   Not required. Defaults to '1000'
#
# [*critical_read_wait*]
#   The critical level for average read wait time.
#   Not required. Defaults to '200'
#
# [*critical_write_wait*]
#   The critical level for average write wait time.
#   Not required. Defaults to '300'
#
# [*critical_service_wait*]
#   The critical level for average service wait time.
#   Not required. Defaults to '200'
#
# [*critical_cpu_util*]
#   The critical level for average cpu utilisation
#   Not required. Defaults to '100'
#
# [*service_groups*]
#   Whether to set up service_groups per virtual machine
#   Not required. Defaults to false
#
# [*parent*]
#   The parent to use in the iostat group
#   Not required. Defaults to xenhost
#
# === Variables
#
# [*drive*]
#   This is an array built from the blockdevices fact. It should be an array of
#   all the drives.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com>
class nagios::nrpe::iostat (
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $nagios_alias           = $::hostname,
  $warning_io_wait        = '1000',
  $warning_read_wait      = '100',
  $warning_write_wait     = '200',
  $warning_service_wait   = '100',
  $warning_cpu_util       = '100',
  $critical_io_wait       = '1000',
  $critical_read_wait     = '200',
  $critical_write_wait    = '300',
  $critical_service_wait  = '200',
  $critical_cpu_util      = '100',
  $service_groups         = false,
  $parent                 = $::xenhost) {
  require nagios::nrpe::config
  include nagios::nrpe::service

  ensure_packages('sysstat', {
    'ensure' => 'installed'
  }
  )

  require nagios::nrpe::checks::iostat

  # This is a bit dirty. We could use nagios_servicegroups, but we want some way
  # to be dynamic with our iostat service
  # groups.
  # Easiest way is to throw it all together into a single text file using
  # datacat. Gonna add the xenhost name into the
  # array.

  if $service_groups == true {
    @@datacat_fragment { "${::fqdn} iostat in servicegroup":
      target => '/etc/nagios/conf.d/puppet/servicegroups_iostat.cfg',
      data   => {
        host => [$parent],
      }
      ,
      tag    => "iostat_${monitoring_environment}",
    }

  }

  $drive = split($::used_blockdevices, ',')

  nagios::nrpe::blockdevice::iostat { $drive:
    monitoring_environment => $monitoring_environment,
    nagios_service         => $nagios_service,
    nagios_alias           => $nagios_alias,
    warning_io_wait        => $warning_io_wait,
    warning_read_wait      => $warning_read_wait,
    warning_write_wait     => $warning_write_wait,
    warning_service_wait   => $warning_service_wait,
    warning_cpu_util       => $warning_cpu_util,
    critical_io_wait       => $critical_io_wait,
    critical_read_wait     => $critical_read_wait,
    critical_write_wait    => $critical_write_wait,
    critical_service_wait  => $critical_service_wait,
    critical_cpu_util      => $critical_cpu_util,
    service_groups         => service_groups,
    parent                 => parent
  }

}
