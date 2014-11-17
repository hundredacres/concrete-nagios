class nagios::server::workspacesapi {
  require nagios::server::config
  include nagios::server::service

  file { "workspacesapi_event_handler.sh":
    path    => "/usr/lib/nagios/eventhandlers/workspacesapi_event_handler.sh",
    source  => "puppet:///modules/nagios/workspacesapi_event_handler.sh",
    owner   => root,
    group   => root,
    mode    => "0755",
    ensure  => present,
    before  => Nagios_command[nginx_event_handler],
    require => File["/usr/lib/nagios/eventhandlers"],
  }

  nagios_command { 'workspacesapi_event_handler':
    command_name => 'restart_workspacesapi',
    ensure       => 'present',
    command_line => '/usr/lib/nagios/eventhandlers/nginx_event_handler.sh -h $HOSTADDRESS$ -s $SERVICESTATE$ -t $SERVICESTATETYPE$ -a $SERVICEATTEMPT$',
    target       => "/etc/nagios3/conf.d/puppet/nagios_commands.cfg",
    notify       => Exec["rechmod"],
  }

}