class nagios::server::nrpe {
  require nagios::server::config
  include nagios::server::service

  package { "nagios-nrpe-plugin":
    ensure => installed,
    notify => Service[nagios3],
  }

  #       Automatically added in ubuntu install
  #
  #               nagios_command { 'Check Nrpe':
  #                       command_name => 'check_nrpe',
  #                       ensure       => 'present',
  #                       command_line => '/usr/lib64/nagios/plugins/check_nrpe -H $HOSTADDRESS$ -c $ARG1$',
  #                       target => "/etc/nagios3/conf.d/nagios_commands.cfg",
  #               }

  class clean {


  }

  @motd::register { 'Nagios NRPE Server': }

}
