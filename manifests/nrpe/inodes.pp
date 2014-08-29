class nagios::nrpe::inodes {
  require nagios::nrpe::config
  include nagios::nrpe::service

  file_line { "check_inodes":
    line   => "command[check_inodes]=/usr/lib/nagios/plugins/check_disk -W 15 -C 5 -p /",
    path   => "/etc/nagios/nrpe_local.cfg",
    match  => "command\[check_inodes\]",
    ensure => present,
    notify => Service[nrpe],
  }

  @@nagios_service { "check_inodes_${hostname}":
    check_command       => "check_nrpe_1arg!check_inodes",
    use                 => "generic-service",
    host_name           => $hostname,
    target              => "/etc/nagios3/conf.d/puppet/service_${fqdn}.cfg",
    service_description => "${hostname}_check_inodes",
    tag                 => "${environment}",
  }

}

