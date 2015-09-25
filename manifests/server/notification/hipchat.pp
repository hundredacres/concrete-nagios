class nagios::server::notification::pagerduty ($token, $room, $contacts) {
  include nagios::server::service

  python::pip { 'hipsaint' :
  pkgname       => 'hipsaint',
  ensure        => 'latest',
  owner         => 'nagios',
 }

  nagios_command { 'notify_service_by_hipchat':
    command_line => "hipsaint --token=${token} --room=${room} --type=service --inputs=\"$SERVICEDESC$|$HOSTALIAS$|$LONGDATETIME$|$NOTIFICATIONTYPE$|$HOSTADDRESS$|$SERVICESTATE$|$SERVICEOUTPUT$\" -n",
    target       => '/etc/nagios3/conf.d/puppet/command_hipchat.cfg',
    notify       => Exec['rechmod'],
  }

  nagios_command { 'notify_host_by_hipchat':
    command_line => "hipsaint --token=${token} --room=${room} --type=host --inputs=\"$HOSTNAME$|$LONGDATETIME$|$NOTIFICATIONTYPE$|$HOSTADDRESS$|$HOSTSTATE$|$HOSTOUTPUT$\" -n",
    target       => '/etc/nagios3/conf.d/puppet/command_hipchat.cfg',
    notify       => Exec['rechmod'],
  }

  #  $contacts = hiera('nagios::server::notification::pagerduty::contacts',
  #  undef)

  # if $contacts != undef {
  #  nagios::server::notification::pagerduty_contact { $contacts: }
  create_resources('::nagios::server::notification::pagerduty_contact', 
  $contacts)
  #  }
}