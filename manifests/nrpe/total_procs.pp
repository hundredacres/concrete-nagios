class nagios::nrpe::total_procs ($nagios_service = $nagios::params::nagios_service) inherits nagios::params {
  require nagios::nrpe::config
  include nagios::nrpe::service

  @@nagios_service { "check_total_procs_${hostname}":
    check_command       => "check_nrpe_1arg!check_total_procs",
    use                 => "${nagios_service}",
    host_name           => $hostname,
    target              => "/etc/nagios3/conf.d/puppet/service_${fqdn}.cfg",
    service_description => "${hostname}_check_total_procs",
    tag                 => "${environment}",
  }

  file_line { "check_total_procs_default":
    line   => "command[check_total_procs]=/usr/lib/nagios/plugins/check_procs -w 150 -c 200",
    path   => "/etc/nagios/nrpe.cfg",
    match  => "command\[check_total_procs\]",
    ensure => absent,
    notify => Service[nrpe],
  }

  file_line { "check_total_procs":
    line   => "command[check_total_procs]=/usr/lib/nagios/plugins/check_procs -w 500 -c 600",
    path   => "/etc/nagios/nrpe_local.cfg",
    match  => "command\[check_total_procs\]",
    ensure => present,
    notify => Service[nrpe],
  }

  @motd::register { 'Nagios Total Processes Check': }

}
