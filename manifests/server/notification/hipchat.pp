# == Class: nagios::server::notification::hipchat
#
# This will set up notification commands and plugin for performing hipchat
# notifications. It will also build contacts with some simple defaults suitable
# for hipchat.
#
# === Parameters
#
# [*token*]
#   The hipchat token to authenticate with.
#   Required.
#
# [*contacts*]
#   The hipchat room to sent the messages to.
#   Required.
#
# [*contacts*]
#   A hash of contacts to build, that will build with some suitable defaults for
#   hipchat - these can be overriden.
#   Not required.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com>
class nagios::server::notification::hipchat ($token, $room, $contacts = undef) {
  include nagios::server::service
  require python

  python::pip { 'hipsaint':
    ensure  => 'latest',
    pkgname => 'hipsaint',
    owner   => 'root',
  }

  nagios_command { 'notify_service_by_hipchat':
    command_line => "hipsaint --token=${token} --room=${room} --type=service --inputs=\"\$SERVICEDESC\$|\$HOSTALIAS\$|\$LONGDATETIME\$|\$NOTIFICATIONTYPE\$|\$HOSTADDRESS\$|\$SERVICESTATE\$|\$SERVICEOUTPUT\$\" -n",
<<<<<<< HEAD
    target       => '/etc/nagios/conf.d/puppet/command_hipchat.cfg',
=======
    target       => '/etc/nagios3/conf.d/puppet/command_hipchat.cfg',
>>>>>>> 1e86654231d7c29360426c7db6fb721c0f31061c
    notify       => Exec['rechmod'],
  }

  nagios_command { 'notify_host_by_hipchat':
    command_line => "hipsaint --token=${token} --room=${room} --type=host --inputs=\"\$HOSTNAME\$|\$LONGDATETIME\$|\$NOTIFICATIONTYPE\$|\$HOSTADDRESS\$|\$HOSTSTATE\$|\$HOSTOUTPUT\$\" -n",
<<<<<<< HEAD
    target       => '/etc/nagios/conf.d/puppet/command_hipchat.cfg',
=======
    target       => '/etc/nagios3/conf.d/puppet/command_hipchat.cfg',
>>>>>>> 1e86654231d7c29360426c7db6fb721c0f31061c
    notify       => Exec['rechmod'],
  }

  $defaults = {
    ensure => present,
    service_notification_commands => 'notify_service_by_hipchat',
    service_notification_period   => '24x7',
    service_notification_options  => 'c,r',
    host_notification_commands    => 'notify_host_by_hipchat',
    host_notification_period      => '24x7',
    host_notification_options     => 'd,r',
    email  => '/dev/null',
<<<<<<< HEAD
    target => '/etc/nagios/conf.d/puppet/contact_hipchat.cfg',
=======
    target => '/etc/nagios3/conf.d/puppet/contact_hipchat.cfg',
>>>>>>> 1e86654231d7c29360426c7db6fb721c0f31061c
    notify => Exec['rechmod'],
  }

  if $contacts != undef {
    create_resources('nagios_contact', $contacts, $defaults)
  }
}