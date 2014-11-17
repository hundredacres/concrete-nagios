class nagios::server::event_handler {
  require nagios::server::config
  include nagios::server::service

  file { "event_handler.sh":
    path    => "/usr/lib/nagios/eventhandlers/event_handler.sh",
    source  => "puppet:///modules/nagios/event_handler.sh",
    owner   => nagios,
    group   => nagios,
    mode    => "0755",
    ensure  => present,
    require => File["/usr/lib/nagios/eventhandlers"],
  }

  nagios_command { 'event_handler':
    command_name => 'event_handler',
    ensure       => 'present',
    command_line => '/usr/lib/nagios/eventhandlers/event_handler.sh -h $HOSTADDRESS$ -s $SERVICESTATE$ -t $SERVICESTATETYPE$ -a $SERVICEATTEMPT$ -c $ARG1$',
    target       => "/etc/nagios3/conf.d/puppet/nagios_commands.cfg",
    notify       => Exec["rechmod"],
  }

}