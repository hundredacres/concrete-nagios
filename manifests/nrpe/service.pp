# == Class: nagios::nrpe::service
#
# This will ensure the nrpe service is running and add an nagios_alias 'nrpe'
# for ease
# of restart scripting.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com
class nagios::nrpe::service {
  service { 'nagios-nrpe-server':
    ensure       => running,
    nagios_alias => 'nrpe',
    enable       => true,
    require      => Package['nagios-nrpe-server'],
  }

}
