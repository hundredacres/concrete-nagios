class nagios::server::clean {
  nagios_command { 'Check Nrpe Longtimeout':
    command_name => 'check_nrpe_1arg_longtimeout',
    ensure       => 'present',
    command_line => '/usr/lib/nagios/plugins/check_nrpe -H $HOSTADDRESS$ -c $ARG1$ -t 30',
    target       => "/etc/nagios3/conf.d/puppet/nagios_commands.cfg",
    notify       => Exec["rechmod"],
  }

  nagios_command { 'Check HTTPS nonroot':
    command_name => 'check_https_nonroot',
    ensure       => 'present',
    command_line => '/usr/lib/nagios/plugins/check_http -S -I $HOSTADDRESS$ -H $ARG1$ -u $ARG2$',
    target       => "/etc/nagios3/conf.d/puppet/nagios_commands.cfg",
    notify       => Exec["rechmod"],
  }

  nagios_command { 'Check HTTP nonroot custom port':
    command_name => 'check_http_nonroot_custom_port',
    ensure       => 'present',
    command_line => '/usr/lib/nagios/plugins/check_http -I $HOSTADDRESS$ -H $ARG1$ -u $ARG2$ -p $ARG3$',
    target       => "/etc/nagios3/conf.d/puppet/nagios_commands.cfg",
    notify       => Exec["rechmod"],
  }

}