# == Class: nagios::server::clean
#
# A class to create commands that are used in some of the services submitted.
# This is currently only deployed to the test server (otherwise they are defined
# manually). In the case that we rebuild the current nagios servers, this should
# be used globally and probably renamed.
#
# === Parameters
#
# [*pagerduty*]
#   Whether or not to set up the pagerduty notification plugin and commands.
#   Not required. Defaults to true
#
# [*hipchat*]
#   Whether or not to set up the hipchat notification plugin and commands.
#   Not required. Defaults to true
#
# [*email*]
#   Whether or not to set up the email plugin and commands.
#   Not required. Defaults to true
#
# [*event_handler*]
#   Whether or not to set up the event_handler plugin and commands.
#   Not required. Defaults to true
#
# [*nrpe*]
#   Whether or not to set up the nrpe plugin and commands.
#   Not required. Defaults to true
#
# [*check_mssql_health*]
#   Whether or not to set up the check_mssql_health plugin and commands.
#   Not required. Defaults to true
#
# [*check_mssql*]
#   Whether or not to set up the check_mssql plugin and commands.
#   Not required. Defaults to true
#
# [*time_periods*]
#   A hash of time_periods to set up for nagios.
#   Not required.
#
# [*$commands*]
#   A hash of $commands to set up for nagios.
#   Not required.
#
# [*contacts*]
#   A hash of contacts to set up for nagios.
#   Not required.
#
# [*contact_groups*]
#   A hash of contact_groups to set up for nagios.
#   Not required.
#
# [*services*]
#   A hash of services to set up for nagios.
#   Not required.
#
# [*hosts*]
#   A hash of hosts to set up for nagios.
#   Not required.
#
# [*admin_email*]
#   The admin_email to set. This is the address that emails will be sent from,
#   if you use them.
#   Not required. Defaults to nagios@$hostname
# 
# [*service_check_timeout*]
#  Timeout for checks
# 
# === Authors
#
# Ben Field <ben.field@concreteplatform.com
class nagios::server::clean (
  $pagerduty          = true,
  $hipchat            = true,
  $email              = true,
  $event_handler      = true,
  $nrpe               = true,
  $check_mssql_health = true,
  $check_mssql        = true,
  $time_periods       = undef,
  $commands           = undef,
  $contacts           = undef,
  $contact_groups     = undef,
  $services           = undef,
  $hosts              = undef,
  $service_check_timeout = '120',
  $admin_email        = "nagios@${::hostname}") {
  include nagios::server::service
  require nagios::server::config

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
    command_line => '/usr/lib/nagios/plugins/check_http -S --sni -I $HOSTADDRESS$ -H $ARG1$ -u $ARG2$ -p $ARG3$  --onredirect=sticky -e 200,302',
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
    command_line => '/usr/lib/nagios/plugins/check_http -S --sni -I $HOSTADDRESS$ -H $ARG1$ -u $ARG2$ -p $ARG3$ -s $ARG4$ --onredirect=sticky',
    target       => '/etc/nagios3/conf.d/puppet/command_nagios.cfg',
    notify       => Exec['rechmod'],
  }

  file_line { 'admin_email':
    ensure => present,
    line   => "admin_email=${admin_email}",
    path   => '/etc/nagios3/nagios.cfg',
    match  => 'admin_email',
    notify => Service['nagios3'],
  }
  
  file_line { 'service_check_timeout':
    ensure => present,
    line   => "service_check_timeout=${service_check_timeout}",
    path   => '/etc/nagios3/nagios.cfg',
    match  => '^service_check_timeout.*$',
    notify => Service['nagios3'],
  }
  
  file { '/var/lib/nagios3/rw/':
    ensure => directory,
    mode   => '0750'
  }

  if $pagerduty == true {
    class { '::nagios::server::notification::pagerduty': }
  }

  if $hipchat == true {
    class { '::nagios::server::notification::hipchat': }
  }

  if $email == true {
    class { '::nagios::server::notification::email': }
  }

  if $event_handler == true {
    class { '::nagios::server::plugins::event_handler': }
  }

  if $nrpe == true {
    class { '::nagios::server::plugins::nrpe': }
  }

  if $check_mssql_health == true {
    class { '::nagios::server::plugins::check_mssql_health': }
  }

  if $check_mssql == true {
    class { '::nagios::server::plugins::check_mssql': }
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
      target => '/etc/nagios3/conf.d/puppet/contact_groups_nagios.cfg',
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