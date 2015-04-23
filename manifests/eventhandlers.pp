# == Class: nagios::eventhandlers
#
# This creates the eventhandlers folder for the clients and the servers that
# require it. Has been factored into a single folder for simplicity.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com
class nagios::eventhandlers {
  file { '/usr/lib/nagios/eventhandlers':
    ensure  => directory,
    recurse => true,
    owner   => 'nagios',
    group   => 'nagios',
    mode    => '0755',
  }

}