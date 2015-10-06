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
class nagios::server::clean (
  $pagerduty          = true,
  $hipchat            = true,
  $event_handler      = true,
  $nrpe               = true,
  $check_mssql_health = true,
  $time_periods       = undef,
  $commands           = undef,
  $contacts           = undef,
  $contact_groups     = undef,
  $services           = undef,
  $hosts              = undef) {
  include nagios::server::service
  require nagios::server::config

  nagios_command { 'Check Nrpe Longtimeout':
    ensure       => 'present',
    command_name => 'check_nrpe_1arg_longtimeout',
    command_line => '/usr/lib/nagios/plugins/check_nrpe -H $HOSTADDRESS$ -c $ARG1$ -t 30',
    target       => '/etc/nagios3/conf.d/puppet/command_nagios.cfg',
    notify       => Exec['rechmod'],
  }

  nagios_command { 'Check HTTP nonroot custom port':
    ensure       => 'present',
    command_name => 'check_http_nonroot_custom_port',
    command_line => '/usr/lib/nagios/plugins/check_http -I $HOSTADDRESS$ -H $ARG1$ -u $ARG2$ -p $ARG3$  --onredirect=sticky -e 200,302',
    target       => '/etc/nagios3/conf.d/puppet/command_nagios.cfg',
    notify       => Exec['rechmod'],
  }

  nagios_command { 'Check HTTPS nonroot custom port':
    ensure       => 'present',
    command_name => 'check_https_nonroot_custom_port',
    command_line => '/usr/lib/nagios/plugins/check_http _S -I $HOSTADDRESS$ -H $ARG1$ -u $ARG2$ -p $ARG3$  --onredirect=sticky -e 200,302',
    target       => '/etc/nagios3/conf.d/puppet/command_nagios.cfg',
    notify       => Exec['rechmod'],
  }

  nagios_command { 'Check HTTP custom string nonroot custom port':
    ensure       => 'present',
    command_name => 'check_http_custom_string_nonroot_custom_port',
    command_line => '/usr/lib/nagios/plugins/check_http -I $HOSTADDRESS$ -H $ARG1$ -u $ARG2$ -p $ARG3$ -s $ARG4$ --onredirect=sticky',
    target       => '/etc/nagios3/conf.d/puppet/command_nagios.cfg',
    notify       => Exec['rechmod'],
  }

  nagios_command { 'Check HTTPS custom string nonroot custom port':
    ensure       => 'present',
    command_name => 'check_https_custom_string_nonroot_custom_port',
    command_line => '/usr/lib/nagios/plugins/check_http -S -I $HOSTADDRESS$ -H $ARG1$ -u $ARG2$ -p $ARG3$ -s $ARG4$ --onredirect=sticky',
    target       => '/etc/nagios3/conf.d/puppet/command_nagios.cfg',
    notify       => Exec['rechmod'],
  }

  if $pagerduty == true {
    class { '::nagios::server::notification::pagerduty': }
  }

  if $hipchat == true {
    class { '::nagios::server::notification::hipchat': }
  }

  if $event_handler == true {
    class { '::nagios::server::plugins::event_handler': }
  }

  if $nrpe == true {
    class { '::nagios::server::plugins::nrpe': }
  }

  if $check_mssql_health == true {
    class { '::nagios::server::plugins::nrpe': }
  }

  if $time_periods != undef {
    create_resources('nagios_timeperiod', $time_periods, {
      target => '/etc/nagios3/conf.d/puppet/timeperiod_nagios.cfg',
      notify => Exec['rechmod']
    }
    )
  }

  if $commands != undef {
    create_resources('nagios_command', $commands, {
      target => '/etc/nagios3/conf.d/puppet/command_nagios.cfg',
      notify => Exec['rechmod']
    }
    )
  }

  if $contacts != undef {
    create_resources('nagios_contact', $contacts, {
      target => '/etc/nagios3/conf.d/puppet/contact_nagios.cfg',
      notify => Exec['rechmod']
    }
    )
  }

  if $contact_groups != undef {
    create_resources('nagios_contactgroup', $contact_groups, {
      target => '/etc/nagios3/conf.d/puppet/contactgroup_nagios.cfg',
      notify => Exec['rechmod']
    }
    )
  }

  if $services != undef {
    create_resources('nagios_service', $services, {
      target => '/etc/nagios3/conf.d/puppet/service_nagios.cfg',
      notify => Exec['rechmod']
    }
    )
  }

  if $hosts != undef {
    create_resources('nagios_host', $hosts, {
      target => '/etc/nagios3/conf.d/puppet/host_nagios.cfg',
      notify => Exec['rechmod']
    }
    )
  }
}