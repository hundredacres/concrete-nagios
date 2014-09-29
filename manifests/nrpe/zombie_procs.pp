class nagios::nrpe::zombie_procs (
  $nagios_service = $nagios::params::nagios_service
  ) inherits nagios::params {
  require nagios::nrpe::config
  include nagios::nrpe::service

  @@nagios_service { "check_zombie_procs_${hostname}":
    check_command       => "check_nrpe_1arg!check_zombie_procs",
    use                 => "${nagios_service}",
    host_name           => $hostname,
    target              => "/etc/nagios3/conf.d/puppet/service_${fqdn}.cfg",
    service_description => "${hostname}_check_zombie_procs",
    tag                 => "${environment}",
  }

  @basic_server::motd::register { 'Nagios Zombie Processes Check': }

}

