# == Class: nagios::server::notification::pagerduty
#
# This will set up notification commands and plugin for performing pagerduty
# notifications. It will also build contacts with some simple defaults suitable
# for pagerduty.
#
# IMPORTANT NOTE: It requires you to have already set up the apt repositories
# from https://www.pagerduty.com/docs/guides/agent-install-guide/
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

  package { 'pdagent': ensure => installed, }

  package { 'pdagent-integrations': ensure => installed, }

  nagios_command { 'notify_service_by_pagerduty':
    command_line => '/usr/share/pdagent-integrations/bin/pd-nagios -n service -k $CONTACTPAGER$ -t "$NOTIFICATIONTYPE$" -f SERVICEDESC="$SERVICEDESC$" -f SERVICESTATE="$SERVICESTATE$" -f HOSTNAME="$HOSTNAME$" -f SERVICEOUTPUT="$SERVICEOUTPUT$"',
<<<<<<< HEAD
    target       => '/etc/nagios/conf.d/puppet/command_pagerduty.cfg',
=======
    target       => '/etc/nagios3/conf.d/puppet/command_pagerduty.cfg',
>>>>>>> 1e86654231d7c29360426c7db6fb721c0f31061c
    notify       => Exec['rechmod'],
  }

  nagios_command { 'notify_host_by_pagerduty':
    command_line => '/usr/share/pdagent-integrations/bin/pd-nagios -n host -k $CONTACTPAGER$ -t "$NOTIFICATIONTYPE$" -f HOSTNAME="$HOSTNAME$" -f HOSTSTATE="$HOSTSTATE$"',
<<<<<<< HEAD
    target       => '/etc/nagios/conf.d/puppet/command_pagerduty.cfg',
=======
    target       => '/etc/nagios3/conf.d/puppet/command_pagerduty.cfg',
>>>>>>> 1e86654231d7c29360426c7db6fb721c0f31061c
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
<<<<<<< HEAD
    target => '/etc/nagios/conf.d/puppet/contact_pagerduty.cfg',
=======
    target => '/etc/nagios3/conf.d/puppet/contact_pagerduty.cfg',
>>>>>>> 1e86654231d7c29360426c7db6fb721c0f31061c
    notify => Exec['rechmod'],
  }

  if $contacts != undef {
    create_resources('nagios_contact', $contacts, $defaults)
  }
}