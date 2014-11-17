class nagios::server::clean {
  # This class is for newbuilt nagios servers. If we decide to rebuild/clean our prod servers, we should stop this being a seperate
  # class.

  #       Automatically added in ubuntu install
  #
  #               nagios_command { 'Check Nrpe':
  #                       command_name => 'check_nrpe',
  #                       ensure       => 'present',
  #                       command_line => '/usr/lib64/nagios/plugins/check_nrpe -H $HOSTADDRESS$ -c $ARG1$',
  #                       target => "/etc/nagios3/conf.d/nagios_commands.cfg",
  #               }

  nagios_command { 'Check Nrpe Longtimeout':
    command_name => 'check_nrpe_1arg_longtimeout',
    ensure       => 'present',
    command_line => '/usr/lib/nagios/plugins/check_nrpe -H $HOSTADDRESS$ -c $ARG1$ -t 30',
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

  nagios_command { 'Check HTTPS nonroot custom port':
    command_name => 'check_https_nonroot_custom_port',
    ensure       => 'present',
    command_line => '/usr/lib/nagios/plugins/check_http -S -I $HOSTADDRESS$ -H $ARG1$ -u $ARG2$ -p $ARG3$',
    target       => "/etc/nagios3/conf.d/puppet/nagios_commands.cfg",
    notify       => Exec["rechmod"],
  }

}