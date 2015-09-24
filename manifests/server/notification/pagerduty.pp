class nagios::server::notification::pagerduty ($pager) {
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

  $contacts = hiera('nagios::server::notification::pagerduty::contacts', undef)

  if $contacts != undef {
    create_resources(::nagios::server::notification::pagerduty_contact, 
    $contacts)
  }

}