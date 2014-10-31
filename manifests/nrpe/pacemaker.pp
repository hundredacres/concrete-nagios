class nagios::nrpe::pacemaker ($nagios_service = $nagios::params::nagios_service) inherits nagios::params {
  require nagios::nrpe::config
  include nagios::nrpe::service
  require heartbeat::virtualip
  
  file_line { "pacemaker_sudoers":
		line => "nagios ALL=(ALL) NOPASSWD: /usr/sbin/crm_mon -s",
		path => "/etc/sudoers",
		ensure => present,
		before => File_line["resync_ntp"],
}
  
  file_line { "check_pacemaker":
    line   => "command[check_pacemaker]=/usr/bin/sudo /usr/sbin/crm_mon -s",
    path   => "/etc/nagios/nrpe_local.cfg",
    match  => "command\[check_pacemaker\]",
    ensure => present,
    notify => Service[nrpe],
  }
  
    @@nagios_service { "check_pacemaker_${hostname}":
    check_command       => "check_nrpe_1arg!check_pacemaker",
    use                 => "${nagios_service}",
    host_name           => $hostname,
    target              => "/etc/nagios3/conf.d/puppet/service_${fqdn}.cfg",
    service_description => "${hostname}_check_pacemaker",
    tag                 => "${environment}",
  }

  @motd::register { 'Nagios Pacemaker Check': }
  
}