# == Class: nagios::nrpe::ntp
#
# This check will test ntp against a server to measure the time difference.
# Currently it is comparing the time to the nagios server, but this could easily
# be changed.
#
# The changes on the client are actually all related to the event handler used
# to resync ntp. It will generate a script to do this (requires the ntp package
# already installed) and generate the current sudo permissions and command. This
# requires the server to have nagios::server::event_handler installed. This is
# the generic server event_handler also used by the nagios::nrpe::process check.
#
# === Variables
#
# [*nagios_service*]
#   This is the generic service it will implement. This is set from
#   nagios::params. This should be set by heira in the future.
#
# [*server*]
#   This is the ip that the check will compare times against. Currently this
#   uses the nagios server. This should potentially be changed to the ntp server
#   and set to use heira.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com
class nagios::nrpe::ntp (
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $server                 = $::nagios::nrpe::config::server,
  $alias                  = $::hostname,) {
  require nagios::nrpe::config
  require basic_server::ntp
  include nagios::nrpe::service

  file { 'resync_ntp.sh':
    ensure  => present,
    path    => '/usr/lib/nagios/eventhandlers/resync_ntp.sh',
    source  => 'puppet:///modules/nagios/resync_ntp.sh',
    owner   => 'nagios',
    group   => 'nagios',
    mode    => '0755',
    before  => File_line['resync_ntp'],
    require => File['/usr/lib/nagios/eventhandlers'],
  }

  # add nagios to sudoers so it can stop/start ntp
  file_line { 'ntp_sudoers':
    ensure => present,
    line   => 'nagios ALL=(ALL) NOPASSWD: /etc/init.d/ntp stop, /etc/init.d/ntp start, /usr/sbin/ntpd -q',
    path   => '/etc/sudoers',
    before => File_line['resync_ntp'],
  }

  file_line { 'check_time_sync':
    ensure => present,
    line   => "command[check_time_sync]=/usr/lib/nagios/plugins/check_ntp_time -H ${server} -w 0.5 -c 1",
    path   => '/etc/nagios/nrpe_local.cfg',
    match  => 'command\[check_time_sync\]',
    notify => Service['nrpe'],
  }

  file_line { 'resync_ntp':
    ensure => present,
    line   => 'command[resync_ntp]=/usr/lib/nagios/eventhandlers/resync_ntp.sh',
    path   => '/etc/nagios/nrpe_local.cfg',
    notify => Service['nrpe'],
  }

  @@nagios_service { "check_time_sync_${alias}":
    check_command       => 'check_nrpe_1arg!check_time_sync',
    use                 => $nagios_service,
    host_name           => $alias,
    target              => "/etc/nagios3/conf.d/puppet/service_${::fqdn}.cfg",
    service_description => "${alias}_check_time_sync",
    tag                 => $monitoring_environment,
    event_handler       => 'event_handler!resync_ntp',
  }

  @motd::register { 'NTP Check and Restart script': }
}
