# == Class: nagios::params
#
# This creates the eventhandlers folder for the clients and the servers that
# require it. Has been factored into a single folder for simplicity.
#
# === Parameters
#
# [*service_class*]
#   An override from puppet dashboard for nagios_service such as
#   generic-service-urgent
#
# === Variables
#
# [*nagios_service*]
#   This is the generic service it will implement. This can be overriden by
#   service_class from puppet dashboard.
#
# [*server*]
#   The address of the nagios server. This should only be used for the ntp check
#   so should really be ntp_server.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com
class nagios::params {
  case $::environment {
    'production'  : { $server = '192.168.100.5' }
    'testing'     : { $server = '192.168.90.223' }
    'development' : { $server = '192.168.90.99' }
    default       : { $server = '192.168.90.223' }
  }

  if ($::service_class == '' or $::service_class == nil or $::service_class == 
  undef) {
    # Casing this in case we decide to unify our generic definitions.
    case $::environment {
      'production'  : { $nagios_service = 'generic-service' }
      'testing'     : { $nagios_service = 'generic-service' }
      'development' : { $nagios_service = 'generic-service' }
      default       : { $nagios_service = 'generic-service' }
    }
  } else {
    # Casing this in case we decide to unify our generic definitions.
    $nagios_service = $::service_class
  }
}