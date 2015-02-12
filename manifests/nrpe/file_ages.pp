# == Define: nagios::nrpe::file_ages
#
# This class will allow us to check the number of files in a folder, with an age
# below a certain level, is above a certain threshold. This is useful for
# checking that a file/report generating process is correctly running. We could
# probably fold this into the file_count check for simplicity.
#
# === Parameters
#
# [*namevar*]
#   The directory will default to the name of the resource. This is the
#   directory that the file count will be run on.
#
# [*warning*]
#   The warning age level. It will warn on nagios if the file count younger than
#   this age goes below the threshold.
#   Not required. Defaults to 7.
#
# [*critical*]
#   The critical age level. It will warn on nagios if the file count younger than
#   this age goes below the threshold.
#   Not required. Defaults to 14.
#
# [*recurse*]
#   Boolean for whether the file count should recurse into sub folders.
#   Not required. Defaults to true.
#
# [*number*]
#   Minimum number of files. 
#   Not required. Defaults to 1.
#
# === Variables
#
# [*nagios_service*]
#   This is the generic service it will implement. This is set from
#   nagios::params. This should be set by heira in the future.
#
# [*command*]
#   This is the command that nrpe will use to check the file count.
#
# === Examples
#
#  nagios::nrpe::file_ages { "/var/www/repo/apt/incoming":
#    warning  => "7",
#    critical => "14",
#    recurse  => true,
#    number   => "1",
#  }
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com>
define nagios::nrpe::file_ages (
  $directory = $name,
  $warning   = '7',
  $critical  = '14',
  $recurse   = true,
  $number       = '1') {
  require nagios::nrpe::config
  include nagios::nrpe::service
  include nagios::params

  require nagios::nrpe::checks::file_ages

  $nagios_service = $::nagios::params::nagios_service
  
    include basic_server::params

  $monitoring_environment = $::basic_server::params::monitoring_environment

  if $recurse == true {
    $command = "command[check_file_ages_${directory}]=/usr/lib/nagios/plugins/check_file_ages.sh -w ${warning} -c ${critical} -r -d ${directory} -a ${number}"
  } else {
    $command = "command[check_file_ages_${directory}]=/usr/lib/nagios/plugins/check_file_ages.sh -w ${warning} -c ${critical} -d ${directory} -a ${number}"
  }

  file_line { "check_file_ages_${directory}":
    ensure => present,
    line   => $command,
    path   => '/etc/nagios/nrpe_local.cfg',
    match  => "command\[check_file_ages_${directory}\]",
    notify => Service[nrpe],
  }

  @@nagios_service { "check_file_ages_${directory}_on_${::hostname}":
    check_command       => "check_nrpe_1arg!check_file_ages_${directory}",
    use                 => $nagios_service,
    host_name           => $::hostname,
    target              => "/etc/nagios3/conf.d/puppet/service_${::fqdn}.cfg",
    service_description => "${::hostname}_check_file_ages_${directory}",
    tag                 => $monitoring_environment,
  }

  @motd::register { "Nagios File Ages Check on ${directory}": }

}