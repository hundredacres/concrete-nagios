# == Define: nagios::server::collector
#
# This will collect the various submitted nagios configs and create the files.
# This is necessary as you cannot correctly order collectors otherwise.
#
# === Parameters
#
# [*monitoring_environment*]
#   This is the environment that the check will be submitted for. This will
#   default to the value set by nagios::server::config but can be overridden here.
#   Not required. 
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com
define nagios::server::collector (
  $monitoring_environment = $::nagios::server::config::monitoring_environment) {
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
