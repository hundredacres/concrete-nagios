# == Class: nagios::client
#
# This is going to create the host definition for each client.
#
# === Paramters
#
# [*monitoring_environment*]
#   This is the environment that the ping check and the client will be submitted
#   for.
#   Required.
#
# [*nagios_service*]
#   This is the generic service that the ping check will implement.
#   Required.
#
# [*parent*]
#   This is the parent for the nagios client (this needs to also be a nagios
#   client for nagios to work). It will default to the xenhost fact which will
#   not necessarily work. If this is set to 'physical' it will disable
#   parenting.
#
# [*nagios_alias*]
#   This is the hostname that the check and client will be submitted for. This
#   should almost always be the hostname, but could be overriden, for instance
#   when submitting a check for a virtual ip.
#
# [*address*]
#   The ip address of the client. Will default to the eth0 address.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com>
class nagios::client (
  $nagios_service,
  $monitoring_environment,
  $parent       = $::xenhost,
  $nagios_alias = $::hostname,
  $address      = $::ipaddress_eth0) {
  # The not hugely neat way, need to refactor this:

  if $parent != 'physical' {
    @@nagios_host { $nagios_alias:
      ensure          => present,
      target          => "/etc/nagios/conf.d/puppet/host_${nagios_alias}.cfg",
      address         => $address,
      use             => 'generic-host',
      alias           => $nagios_alias,
      tag             => $monitoring_environment,
      parents         => $parent,
      icon_image      => 'base/linux40.png',
      statusmap_image => 'base/linux40.gd2',
    }
  } else {
    @@nagios_host { $nagios_alias:
      ensure          => present,
      target          => "/etc/nagios/conf.d/puppet/host_${nagios_alias}.cfg",
      address         => $address,
      use             => 'generic-host',
      alias           => $nagios_alias,
      tag             => $monitoring_environment,
      icon_image      => 'base/linux40.png',
      statusmap_image => 'base/linux40.gd2',
    }
  }

  @@nagios_service { "check_ping_${nagios_alias}":
    target              => "/etc/nagios/conf.d/puppet/service_${nagios_alias}.cfg",
    check_command       => 'check_ping!100.0,20%!500.0,60%',
    use                 => $nagios_service,
    host_name           => $nagios_alias,
    service_description => "${nagios_alias}_check_ping",
    require             => Nagios_host[$nagios_alias],
    tag                 => $monitoring_environment,
  }

}
