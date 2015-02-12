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
# === Variables
#
# [*drive*]
#   This is an array built from the blockdevices fact. It should be an array of
#   all the drives.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com
class nagios::nrpe::iostat {
  require nagios::nrpe::config
  require basic_server::basic_software
  include nagios::nrpe::service

  require nagios::nrpe::checks::iostat

  include basic_server::params

  $monitoring_environment = $::basic_server::params::monitoring_environment

  # This is a bit dirty. We could use nagios_servicegroups, but we want some way
  # to be dynamic with our iostat service
  # groups.
  # Easiest way is to throw it all together into a single text file using
  # datacat. Gonna add the xenhost name into the
  # array.

  @@datacat_fragment { "${::fqdn} iostat in servicegroup":
    target => '/etc/nagios3/conf.d/puppet/servicegroups_iostat.cfg',
    data   => {
      host => [$::xenhost],
    }
    ,
    tag    => "iostat_${monitoring_environment}",
  }

  $drive = split($::used_blockdevices, ',')

  nagios::nrpe::blockdevice::iostat { $drive: }

}
