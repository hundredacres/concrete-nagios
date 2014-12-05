# == Class: nagios::nrpe::config
#
# This will install the nrpe client, install basic plugins and create the eventhandler folder.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com
class nagios::nrpe::package {
  require stdlib
  include nagios::eventhandlers

  package { ['nagios-nrpe-server', 'nagios-plugins-basic']: ensure => installed, }

}
