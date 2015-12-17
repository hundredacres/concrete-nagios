# == Class: nagios::server::notification::email
#
# This is ensure that mailutils is installed and set up commands for emailing
# alerts to contacts. It will also build contacts with some simple defaults
# suitable for emails.
#
# === Parameters
#
# [*contacts*]
#   A hash of contacts to build, that will build with some suitable defaults for
#   emails - these can be overriden.
#   Not required.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com>
class nagios::server::notification::email ($contacts = undef) {
  include nagios::server::service

  ensure_packages('heirloom-mailx', {
    'ensure' => 'installed'
  }
  )

  nagios_command { 'notify_host_by_email':
    command_line => '/usr/bin/printf "%b" "***** Nagios *****\n\nNotification Type: $NOTIFICATIONTYPE$\nHost: $HOSTNAME$\nState: $HOSTSTATE$\nAddress: $HOSTADDRESS$\nInfo: $HOSTOUTPUT$\n\nDate/Time: $LONGDATETIME$\n" | /usr/bin/mailx -r $ADMINEMAIL$ -s "** $NOTIFICATIONTYPE$ Host Alert: $HOSTNAME$ is $HOSTSTATE$ **" $CONTACTEMAIL$',
    target       => '/etc/nagios3/conf.d/puppet/command_email.cfg',
    notify       => Exec['rechmod'],
  }

  nagios_command { 'notify_service_by_email':
    command_line => '/usr/bin/printf "%b" "***** Nagios *****\n\nNotification Type: $NOTIFICATIONTYPE$\n\nService: $SERVICEDESC$\nHost: $HOSTALIAS$\nAddress: $HOSTADDRESS$\nState: $SERVICESTATE$\n\nDate/Time: $LONGDATETIME$\n\nAdditional Info:\n\n$SERVICEOUTPUT$\n" | /usr/bin/mailx -r $ADMINEMAIL$ -s "** $NOTIFICATIONTYPE$ Service Alert: $HOSTALIAS$/$SERVICEDESC$ is $SERVICESTATE$ **" $CONTACTEMAIL$',
    target       => '/etc/nagios3/conf.d/puppet/command_email.cfg',
    notify       => Exec['rechmod'],
  }

  $defaults = {
    ensure => present,
    service_notification_commands => 'notify_service_by_email',
    service_notification_period   => '24x7',
    service_notification_options  => 'u,c,r,f',
    host_notification_commands    => 'notify_host_by_email',
    host_notification_period      => '24x7',
    host_notification_options     => 'd,r,f',
    target => '/etc/nagios3/conf.d/puppet/contact_email.cfg',
    notify => Exec['rechmod'],
  }

  if $contacts != undef {
    create_resources('nagios_contact', $contacts, $defaults)
  }
}