# == Class: nagios::server::clean
#
# A class to create commands that are used in some of the services submitted.
# This is currently only deployed to the test server (otherwise they are defined
# manually). In the case that we rebuild the current nagios servers, this should
# be used globally and probably renamed.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com
class nagios::server::clean {
  include nagios::server::service
  require nagios::server::config

  nagios_command { 'Check Nrpe Longtimeout':
    ensure       => 'present',
    command_name => 'check_nrpe_1arg_longtimeout',
    command_line => '/usr/lib/nagios/plugins/check_nrpe -H $HOSTADDRESS$ -c $ARG1$ -t 30',
    target       => '/etc/nagios3/conf.d/puppet/nagios_commands.cfg',
    notify       => Exec['rechmod'],
  }

  nagios_command { 'Check HTTP nonroot custom port':
    ensure       => 'present',
    command_name => 'check_http_nonroot_custom_port',
    command_line => '/usr/lib/nagios/plugins/check_http -I $HOSTADDRESS$ -H $ARG1$ -u $ARG2$ -p $ARG3$  --onredirect=sticky -e 200,302',
    target       => '/etc/nagios3/conf.d/puppet/nagios_commands.cfg',
    notify       => Exec['rechmod'],
  }

  nagios_command { 'Check HTTPS nonroot custom port':
    ensure       => 'present',
    command_name => 'check_https_nonroot_custom_port',
    command_line => '/usr/lib/nagios/plugins/check_http -S -I $HOSTADDRESS$ -H $ARG1$ -u $ARG2$ -p $ARG3$  --onredirect=sticky -e 200,302',
    target       => '/etc/nagios3/conf.d/puppet/nagios_commands.cfg',
    notify       => Exec['rechmod'],
  }

  nagios_command { 'Check HTTP STRING nonroot custom port':
    ensure       => 'present',
    command_name => 'check_http_string_nonroot_custom_port',
    command_line => '/usr/lib/nagios/plugins/check_http -H $HOSTADDRESS$ -u $ARG1 -p $ARG2 -s $ARG3',
    target       => '/etc/nagios3/conf.d/puppet/command_nagios.cfg',
    notify       => Exec['rechmod'],
  }



  nagios_command { 'Check TCP':
    ensure       => 'present',
    command_name => 'check_tcp',
    command_line => '/usr/lib/nagios/plugins/check_tcp -H $HOSTADDRESS$ -p $ARG1$',
    target       => '/etc/nagios3/conf.d/puppet/nagios_commands.cfg',
    notify       => Exec['rechmod'],
  }

}
