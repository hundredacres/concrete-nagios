class nagios::server::notification::pagerduty (
  $pager,
  $service_notification_options = 'c,r',
  $host_notification_options    = 'd,r') {
  include nagios::server::service

  file { '/usr/local/bin/pagerduty_nagios.pl':
    ensure => present,
    source => 'puppet:///modules/nagios/server/notification/pagerduty_nagios.pl',
    owner  => 'nagios',
    group  => 'nagios',
    mode   => '0755',
  }

  nagios_command { 'notify-service-by-pagerduty':
    command_line => '/usr/local/bin/pagerduty_nagios.pl enqueue -f pd_nagios_object=service',
    target       => '/etc/nagios3/conf.d/puppet/nagios_commands.cfg',
    notify       => Exec['rechmod'],
  }

  nagios_command { 'notify-host-by-pagerduty':
    command_line => '/usr/local/bin/pagerduty_nagios.pl enqueue -f pd_nagios_object=host',
    target       => '/etc/nagios3/conf.d/puppet/nagios_commands.cfg',
    notify       => Exec['rechmod'],
  }

  nagios_contact { 'pagerduty':
    ensure => present,
    alias  => 'Pagerduty Contact',
    service_notification_commands => 'notify-service-by-pagerduty',
    service_notification_period   => '24x7',
    service_notification_options  => $service_notification_options,
    host_notification_commands    => 'notify-host-by-pagerduty',
    host_notification_period      => '24x7',
    host_notification_options     => $host_notification_options,
    target => '/etc/nagios3/conf.d/puppet/nagios_conctacts.cfg',
    notify => Exec['rechmod'],
  }

  $contacts = hiera('nagios::server::notification::pagerduty::contacts', 'none')

  if $contacts == 'none' {
    create_resources(nagios_contact, $contacts)
  }

}