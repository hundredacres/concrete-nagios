class nagios::nrpe::processor ($nagios_service = $nagios::params::nagios_service) inherits nagios::params {
  require nagios::nrpe::config
  include nagios::nrpe::service

  # Fully dynamic load check:

  $loadwarning1 = $::processorcount * 0.9
  $loadwarning5 = $::processorcount * 0.8
  $loadwarning15 = $::processorcount * 0.7
  $loadcritical1 = $::processorcount * 1
  $loadcritical5 = $::processorcount * 0.9
  $loadcritical15 = $::processorcount * 0.8

  # Changing this based on rational that poor disk IO
  # or poor network share IO
  # will bump up calculated load up as well as CPU usage
  # see http://en.wikipedia.org/wiki/Load_(computing)

  # THis is true, but this also means that the load check will not proc when there is NOT IO issues. Correct response is to check
  # iostat / correlate with that.

  # $loadwarning1 = $::processorcount * 1.3
  # $loadwarning5 = $::processorcount * 1.1
  # $loadwarning15 = $::processorcount * 0.9
  # $loadcritical1 = $::processorcount * 1.8
  # $loadcritical5 = $::processorcount * 1.5
  # $loadcritical15 = $::processorcount * 1.1

  $check = "command[check_load]=/usr/lib/nagios/plugins/check_load -w ${loadwarning1},${loadwarning5},${loadwarning15} -c ${loadcritical1},${loadcritical5},${loadcritical15}"

  file_line { "check_load":
    # have to define cases manually as puppet does not handle casting between strings and numbers well
    line   => $check,
    path   => "/etc/nagios/nrpe_local.cfg",
    match  => "command\[check_load\]",
    ensure => present,
    notify => Service[nrpe],
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
    use                 => "${nagios_service}",
    host_name           => $hostname,
    target              => "/etc/nagios3/conf.d/puppet/service_${fqdn}.cfg",
    service_description => "${hostname}_check_load",
    tag                 => "${environment}",
  }

  @motd::register { 'Nagios CPU Load Check': }

}

