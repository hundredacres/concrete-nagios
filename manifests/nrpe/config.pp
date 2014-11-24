# == Class: nagios::nrpe::config
#
# This will perform the configuration of the nrpe so that it allows the server to connect to it.
#
# === Variables
#
# [*hosts*]
#   This will use the variable ${server} from nagios::params to build an allowed hosts string.
#   This should be changed to use heira.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com
class nagios::nrpe::config {
  include nagios::params

  require nagios::nrpe::package
  include nagios::nrpe::service

  $hosts = "allowed_hosts = 127.0.0.1,${::nagios::params::server}"

  file_line { "allowed_hosts":
    line   => $hosts,
    path   => "/etc/nagios/nrpe.cfg",
    match  => "^allowed_hosts",
    ensure => present,
    notify => Service[nrpe],
  }

  @motd::register { 'NRPE End Point': }

}
