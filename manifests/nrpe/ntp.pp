class nagios::nrpe::ntp ($server = $nagios::params::server) inherits nagios::params {
  require nagios::nrpe::config
  require basic_server::ntp
  include nagios::nrpe::service
	include nagios::eventhandlers

  file { "resync_ntp.sh":
    path   => "/usr/lib/nagios/eventhandlers/resync_ntp.sh",
    source => "puppet:///modules/nagios/resync_ntp.sh",
    owner  => root,
    group  => root,
    mode   => "0755",
    ensure => present,
    before => File_line["resync_ntp"],
    require => File["/usr/lib/nagios/eventhandlers"],
  }
  
  #add nagios to sudoers so it can stop/start ntp
  file_line { "ntp_sudoers":
		line => "nagios ALL=(ALL) NOPASSWD: /etc/init.d/ntp stop, /etc/init.d/ntp start, /usr/sbin/ntpd -q",
		path => "/etc/sudoers",
		ensure => present,
		before => File_line["resync_ntp"],
}
  
  file_line { "check_time_sync":
    line   => "command[check_time_sync]=/usr/lib/nagios/plugins/check_ntp_time -H $server -w 0.5 -c 1",
    path   => "/etc/nagios/nrpe_local.cfg",
    match  => "command\[check_time_sync\]",
    ensure => present,
    notify => Service[nrpe],
  }
  
  file_line { "resync_ntp":
		line   => "command[resync_ntp]=/usr/lib/nagios/eventhandlers/resync_ntp.sh",
		path   => "/etc/nagios/nrpe_local.cfg",
		ensure => present,
    notify => Service[nrpe],
	}
	
	@@nagios_service { "check_time_sync_${hostname}":
    check_command       => "check_nrpe_1arg!check_time_sync",
    use                 => "generic-service",
    host_name           => $hostname,
    target              => "/etc/nagios3/conf.d/puppet/service_${fqdn}.cfg",
    service_description => "${hostname}_check_time_sync",
    tag                 => "${environment}",
    event_handler				=> "resync_ntp",
  }
  
  @basic_server::motd::register { 'NTP Check and Restart scrpit': }
}