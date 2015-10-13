# == Class: nagios::server::notification::pagerduty
#
# This will set up notification commands and plugin for performing pagerduty
# notifications. It will also build contacts with some simple defaults suitable
# for pagerduty.
#
# === Parameters
#
# [*pager*]
#   The pager to send messages to.
#   Required.
#
# [*contacts*]
#   A hash of contacts to build, that will build with some suitable defaults for
#   pagerduty - these can be overriden.
#   Not required.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com>
class nagios::server::notification::pagerduty ($pager, $contacts = undef) {
  include nagios::server::service

  file { '/usr/local/bin/pagerduty_nagios.pl':
    ensure => present,
    source => 'puppet:///modules/nagios/server/notification/pagerduty_nagios.pl',
    owner  => 'nagios',
    group  => 'nagios',
    mode   => '0755',
  }

  nagios_command { 'notify_service_by_pagerduty':
    command_line => '/usr/local/bin/pagerduty_nagios.pl enqueue -f pd_nagios_object=service',
    target       => '/etc/nagios3/conf.d/puppet/command_pagerduty.cfg',
    notify       => Exec['rechmod'],
  }

  nagios_command { 'notify_host_by_pagerduty':
    command_line => '/usr/local/bin/pagerduty_nagios.pl enqueue -f pd_nagios_object=host',
    target       => '/etc/nagios3/conf.d/puppet/command_pagerduty.cfg',
    notify       => Exec['rechmod'],
  }

  $defaults = {
    ensure => present,
    service_notification_commands => 'notify_service_by_pagerduty',
    service_notification_period   => '24x7',
    service_notification_options  => 'c,r',
    host_notification_commands    => 'notify_host_by_pagerduty',
    host_notification_period      => '24x7',
    host_notification_options     => 'd,r',
    pager  => $pager,
    target => '/etc/nagios3/conf.d/puppet/contact_pagerduty.cfg',
    notify => Exec['rechmod'],
  }

  if $contacts != undef {
    create_resources('nagios_contact', 
    $contacts, $defaults)
  }
}