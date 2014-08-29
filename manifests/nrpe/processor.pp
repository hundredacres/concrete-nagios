class nagios::nrpe::processor {
  require nagios::nrpe::config
  include nagios::nrpe::service

  case $::processorcount {
    '1'     : { $check = "command[check_load]=/usr/lib/nagios/plugins/check_load -w 0.9,0.7,0.5 -c 1,0.8,0.6" }
    '2'     : { $check = "command[check_load]=/usr/lib/nagios/plugins/check_load -w 1.8,1.4,1 -c 2,1.6,1.2" }
    '3'     : { $check = "command[check_load]=/usr/lib/nagios/plugins/check_load -w 2.7,2.1,1.5 -c 3,2.4,1.8" }
    '4'     : { $check = "command[check_load]=/usr/lib/nagios/plugins/check_load -w 3.6,2.8,2 -c 4,3.2,2.4" }
    default : { $check = "command[check_load]=/usr/lib/nagios/plugins/check_load -w 4.5,3.5,2.5 -c 5,4,3" }
  }

  file_line { "check_load":
    # have to define cases manually as puppet does not handle casting between strings and numbers well
    line   => $check,
    path   => "/etc/nagios/nrpe_local.cfg",
    match  => "command\[check_load\]",
    ensure => present,
    before => File_line[check_load_default],
  }

  file_line { "check_load_default":
    # have to define cases manually as puppet does not handle casting between strings and numbers well
    line   => "command[check_load]=/usr/lib/nagios/plugins/check_load -w 15,10,5 -c 30,25,20",
    path   => "/etc/nagios/nrpe.cfg",
    match  => "command\[check_load\]",
    ensure => absent,
    notify => Service[nrpe],
  }

  @@nagios_service { "check_load_${hostname}":
    check_command       => "check_nrpe_1arg!check_load",
    use                 => "generic-service",
    host_name           => $hostname,
    target              => "/etc/nagios3/conf.d/puppet/service_${fqdn}.cfg",
    service_description => "${hostname}_check_load",
    tag                 => "${environment}",
  }

  @motd::register { 'Nagios CPU Load Check': }

}

