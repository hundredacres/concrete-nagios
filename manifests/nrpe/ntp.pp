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
# === Parameters
#
# [*monitoring_environment*]
#   This is the environment that the check will be submitted for. This will
#   default to the value set by nagios::nrpe::config but can be overridden here.
#   Not required. 
#
# [*nagios_service*]
#   This is the generic service that this check will implement. This should
#   be set by nagios::nrpe::config but can be overridden here. Not required.
#
# [*nagios_alias*]
#   This is the hostname that the check will be submitted for. This should
#   almost always be the hostname, but could be overriden, for instance when
#   submitting a check for a virtual ip. Not required.
#
# [*server*]
#   This is the ip that the check will compare times against. This will default
#   to the nagios server from nagios::nrpe::config
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com
class nagios::nrpe::ntp (
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $server                 = $::nagios::nrpe::config::server,
  $nagios_alias           = $::hostname,) {
  require nagios::nrpe::config
  include nagios::nrpe::service

  file { 'resync_ntp.sh':
    ensure  => present,
    path    => '/usr/lib/nagios/eventhandlers/resync_ntp.sh',
    source  => 'puppet:///modules/nagios/nrpe/resync_ntp.sh',
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

  @@nagios_service { "check_time_sync_${nagios_alias}":
    check_command       => 'check_nrpe_1arg!check_time_sync',
    use                 => $nagios_service,
    host_name           => $nagios_alias,
<<<<<<< HEAD
    target              => "/etc/nagios/conf.d/puppet/service_${nagios_alias}.cfg",
=======
    target              => "/etc/nagios3/conf.d/puppet/service_${nagios_alias}.cfg",
>>>>>>> 1e86654231d7c29360426c7db6fb721c0f31061c
    service_description => "${nagios_alias}_check_time_sync",
    tag                 => $monitoring_environment,
    event_handler       => 'event_handler!resync_ntp',
  }
}
