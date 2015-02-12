# == Define: nagios::server::collector
#
# This will collect the various submitted nagios configs and create the files.
# This is necessary as you cannot correctly order collectors otherwise.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com
define nagios::server::collector {
  include basic_server::params

  $monitoring_environment = $::basic_server::params::monitoring_environment
  
  Nagios_host <<| tag == $monitoring_environment |>> {
  }

  Nagios_service <<| tag == $monitoring_environment |>> {
  }

  Nagios_command <<| tag == $monitoring_environment |>> {
  }

  Nagios_servicegroup <<| tag == $monitoring_environment |>> {
  }

  Nagios_servicedependency <<| tag == $monitoring_environment |>> {
  }

}