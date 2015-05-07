              # == Class: nagios::nrpe::config
#
# This will install the nrpe client, install basic plugins and create the
# eventhandler folder.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com
class nagios::nrpe::package {
  require stdlib

  package { 'nagios-nrpe-server': ensure => installed, }

  package { 'nagios-plugins-basic': ensure => installed, }

}
