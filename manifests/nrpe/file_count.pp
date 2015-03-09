# == Define: nagios::nrpe::file_count
#
# This class will allow us to check the number of files in a folder is below a
# certain threshold. This is useful for checking that a file queue is being
# properly cleared. If there was a need this (and the script) could easily be
# changed to check that the file count is above a threshold. Note: It will not
# count folders.
#
# === Parameters
#
# [*namevar*]
#   The directory will default to the name of the resource. This is the
#   directory that the file count will be run on.
#
# [*warning*]
#   The warning file count level. It will warn on nagios if the file count goes
#   above this level.
#   Not required. Defaults to 5.
#
# [*critical*]
#   The critical file count level. It will show critical on nagios if the file
#   count goes above this level.
#   Not required. Defaults to 10.
#
# [*recurse*]
#   Boolean for whether the file count should recurse into sub folders.
#   Not required. Defaults to true.
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
#  nagios::nrpe::file_count { "/var/www/repo/apt/incoming":
#    warning  => "5",
#    critical => "10",
#    recurse  => true,
#  }
# === Authors
#
# Ben Field <ben.field@concreteplatform.com
define nagios::nrpe::file_count (
  $directory = $name,
  $warning   = '5',
  $critical  = '10',
  $recurse   = true) {
  require nagios::nrpe::config
  include nagios::nrpe::service
  include nagios::params

  require nagios::nrpe::checks::file_count

  $nagios_service = $::nagios::params::nagios_service

  include base::params

  $monitoring_environment = $::base::params::monitoring_environment

  if $recurse == true {
    $command = "command[check_file_count_${directory}]=/usr/lib/nagios/plugins/check_file_count.sh -w ${warning} -c ${critical} -r -d ${directory}"
  } else {
    $command = "command[check_file_count_${directory}]=/usr/lib/nagios/plugins/check_file_count.sh -w ${warning} -c ${critical} -d ${directory}"
  }

  file_line { "check_file_count_${directory}":
    ensure => present,
    line   => $command,
    path   => '/etc/nagios/nrpe_local.cfg',
    match  => "command\[check_file_count_${directory}\]",
    notify => Service[nrpe],
  }

  @@nagios_service { "check_file_count_${directory}_on_${::hostname}":
    check_command       => "check_nrpe_1arg!check_file_count_${directory}",
    use                 => $nagios_service,
    host_name           => $::hostname,
    target              => "/etc/nagios3/conf.d/puppet/service_${::fqdn}.cfg",
    service_description => "${::hostname}_check_file_count_${directory}",
    tag                 => $monitoring_environment,
  }

  @motd::register { "Nagios File Count Check on ${directory}": }

}
