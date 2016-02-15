# == Class: nagios::server::plugins::event_handler
#
# This is going to create the event handler script and command that can then be
# used by client based services for example nagios::nrpe::process. It has a
# standard event handler that should be sufficent for most things, but could be
# extended in the future.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com>
class nagios::server::plugins::event_handler {
  require nagios::server::config
  include nagios::server::service

  file { 'event_handler.sh':
    ensure  => present,
    path    => '/usr/lib/nagios/eventhandlers/event_handler.sh',
    source  => 'puppet:///modules/nagios/server/plugins/event_handler.sh',
    owner   => 'nagios',
    group   => 'nagios',
    mode    => '0755',
    require => File['/usr/lib/nagios/eventhandlers'],
  }

  nagios_command { 'event_handler':
    ensure       => 'present',
    command_name => 'event_handler',
    command_line => '/usr/lib/nagios/eventhandlers/event_handler.sh -h $HOSTADDRESS$ -s $SERVICESTATE$ -t $SERVICESTATETYPE$ -a $SERVICEATTEMPT$ -c $ARG1$',
<<<<<<< HEAD
    target       => '/etc/nagios/conf.d/puppet/command_nagios.cfg',
=======
    target       => '/etc/nagios3/conf.d/puppet/command_nagios.cfg',
>>>>>>> 1e86654231d7c29360426c7db6fb721c0f31061c
    notify       => Exec['rechmod'],
  }

}