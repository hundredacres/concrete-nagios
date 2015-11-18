# == Class: nagios::nrpe::config
#
# This will perform the configuration of the nrpe so that it allows the server
# to connect to it.
#
# === Variables
#
# [*server*]
#   This is the ip address for the nagios server, which will be added to the
#   allowed host line in the nagios nrpe config. Required.
#
# [*monitoring_environment*]
#   This is the environment that the check will be submitted for. This will set
#   the default for all checks added to nodes. Required.
#
# [*nagios_service*]
#   This is the generic service that this check will implement. This will set
#   the default for all checks added to nodes. Required.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com
class nagios::nrpe::config ($server, $nagios_service, $monitoring_environment) {
  require nagios::nrpe::package
  include nagios::nrpe::service

  $hosts = "allowed_hosts=127.0.0.1,${server}"

  file_line { 'allowed_hosts':
    ensure => present,
    line   => $hosts,
    path   => '/etc/nagios/nrpe.cfg',
    match  => '^allowed_hosts',
    notify => Service['nagios-nrpe-server'],
  }

}
