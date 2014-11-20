#Gonna make a generic check that can use the check_file_count script

define nagios::nrpe::file_count ($directory         = $name,
  $warning         = "5",
  $critical        = "10",
  $recurse          = true
  ) {
  require nagios::nrpe::config
  include nagios::nrpe::service
  include nagios::params
  $nagios_service = $::nagios::params::nagios_service
  
  require nagios::nrpe::file_count::package

	if $recurse == true {
	  $command = "command[check_file_count_${directory}]=/usr/lib/nagios/plugins/check_file_count.sh -w ${warning} -c ${critical} -r -d ${directory}"
	} else {
	  $command = "command[check_file_count_${directory}]=/usr/lib/nagios/plugins/check_file_count.sh -w ${warning} -c ${critical} -d ${directory}"
	}

  file_line { "check_file_count_${directory}":
    line   => $command,
    path   => "/etc/nagios/nrpe_local.cfg",
    match  => "command\[check_file_count_${directory}\]",
    ensure => present,
    notify => Service[nrpe],
  }

  @@nagios_service { "check_file_count_${directory}_on_${hostname}":
      check_command       => "check_nrpe_1arg!check_file_count_${directory}",
      use                 => "${nagios_service}",
      host_name           => $hostname,
      target              => "/etc/nagios3/conf.d/puppet/service_${fqdn}.cfg",
      service_description => "${hostname}_check_file_count_${directory}",
      tag                 => "${environment}",
  }

    @motd::register { "Nagios File Count Check on ${directory}": }

}