class nagios::server::ntp {
  require nagios::server::config
  include nagios::server::service
  require nagios::server::event_handler
/*
  nagios_command { 'ntp_event_handler':
    command_name => 'resync_ntp',
    ensure       => 'present',
    command_line => '/usr/lib/nagios/eventhandlers/event_handler.sh -h $HOSTADDRESS$ -s $SERVICESTATE$ -t $SERVICESTATETYPE$ -a $SERVICEATTEMPT$ -c resync_ntp',
    target       => "/etc/nagios3/conf.d/puppet/nagios_commands.cfg",
    notify       => Exec["rechmod"],
  }
  * 
  * 
  */
}