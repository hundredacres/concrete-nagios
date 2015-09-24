define nagios::server::notification::pagerduty_contact (
  $alias = $name,
  $pager = $::nagios::server::notification::pagerduty::pager,
  $service_notification_period  = '24x7',
  $service_notification_options = 'c,r',
  $host_notification_period     = '24x7',
  $host_notification_options    = 'd,r') {
  include nagios::server::service

  nagios_contact { $name:
    ensure => present,
    alias  => $alias,
    service_notification_commands => 'notify_service_by_pagerduty',
    service_notification_period   => $service_notification_period,
    service_notification_options  => $service_notification_options,
    host_notification_commands    => 'notify_host_by_pagerduty',
    host_notification_period      => $host_notification_period,
    host_notification_options     => $host_notification_options,
    pager  => $pager,
    target => '/etc/nagios3/conf.d/puppet/contact_pagerduty.cfg',
    notify => Exec['rechmod'],
  }

}