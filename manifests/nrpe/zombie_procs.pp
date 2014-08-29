class nagios::nrpe::zombie_procs {
  require nagios::nrpe::config
  include nagios::nrpe::service

  @@nagios_service { "check_zombie_procs_${hostname}":
    check_command       => "check_nrpe_1arg!check_zombie_procs",
    use                 => "generic-service",
    host_name           => $hostname,
    target              => "/etc/nagios3/conf.d/puppet/service_${fqdn}.cfg",
    service_description => "${hostname}_check_zombie_procs",
    tag                 => "${environment}",
  }

  @motd::register { 'Nagios Zombie Processes Check': }

}

