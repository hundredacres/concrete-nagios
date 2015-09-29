class nagios::server::notification::hipchat ($token, $room, $contacts = undef) {
  include nagios::server::service
  require python

  python::pip { 'hipsaint':
    pkgname => 'hipsaint',
    ensure  => 'latest',
    owner   => 'root',
  }

  nagios_command { 'notify_service_by_hipchat':
    command_line => "hipsaint --token=${token} --room=${room} --type=service --inputs=\"\$SERVICEDESC\$|\$HOSTALIAS\$|\$LONGDATETIME\$|\$NOTIFICATIONTYPE\$|\$HOSTADDRESS\$|\$SERVICESTATE\$|\$SERVICEOUTPUT\$\" -n",
    target       => '/etc/nagios3/conf.d/puppet/command_hipchat.cfg',
    notify       => Exec['rechmod'],
  }

  nagios_command { 'notify_host_by_hipchat':
    command_line => "hipsaint --token=${token} --room=${room} --type=host --inputs=\"\$HOSTNAME\$|\$LONGDATETIME\$|\$NOTIFICATIONTYPE\$|\$HOSTADDRESS\$|\$HOSTSTATE\$|\$HOSTOUTPUT\$\" -n",
    target       => '/etc/nagios3/conf.d/puppet/command_hipchat.cfg',
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
    email  => '/dev/null',
    target => '/etc/nagios3/conf.d/puppet/contact_hipchat.cfg',
    notify => Exec['rechmod'],
  }

  if $contacts != undef {
    create_resources('::nagios::server::notification::hipchat_contact', 
    $contacts, $defaults)
  }
}