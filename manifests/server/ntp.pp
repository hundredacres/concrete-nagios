class nagios::server::ntp {
  require nagios::server::config
  include nagios::server::service

  # This should be factored out when we need a second eventhandler
  file { "/usr/lib/nagios/eventhandlers":
    ensure  => directory,
    recurse => true,
    owner   => root,
    group   => root,
    mode    => 755,
    before  => File["ntp_event_handler.sh"],
  }

  file { "ntp_event_handler.sh":
    path   => "/usr/lib/nagios/eventhandlers/ntp_event_handler.sh",
    source => "puppet:///modules/nagios/ntp_event_handler.sh",
    owner  => root,
    group  => root,
    mode   => "0755",
    ensure => present,
    before => Nagios_command[ntp_event_handler],
  }

  nagios_command { 'ntp_event_handler':
    command_name => 'resync_ntp',
    ensure       => 'present',
    command_line => '/usr/lib/nagios/eventhandlers/ntp_event_handler.sh -h $HOSTADDRESS$ -s $SERVICESTATE$ -t $SERVICESTATETYPE$ -a $SERVICEATTEMPT$',
    target       => "/etc/nagios3/conf.d/puppet/nagios_commands.cfg",
    notify       => Exec["rechmod"],
  }
}