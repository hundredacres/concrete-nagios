# == Define: nagios::server::collector
#
# This will collect the various submitted nagios configs and create the files. This is necessary as you cannot correctly
# order collectors otherwise.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com
define nagios::server::collector {
  Nagios_host <<| tag == $::environment |>> {
  }

  Nagios_service <<| tag == $::environment |>> {
  }

  Nagios_command <<| tag == $::environment |>> {
  }

  Nagios_servicegroup <<| tag == $::environment |>> {
  }

  Nagios_servicedependency <<| tag == $::environment |>> {
  }

}