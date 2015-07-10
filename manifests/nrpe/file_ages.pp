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
#   The critical age level. It will warn on nagios if the file count younger
#   than
#   this age goes below the threshold.
#   Not required. Defaults to 14.
#
# [*recurse*]
#   Boolean for whether the file count should recurse into sub folders.
#   Not required. Defaults to true.
#
# [*type*]
#   The type of file to check for (file, directory or both).
#   Not require. Defaults to file.
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
  $directory              = $name,
  $warning                = '7',
  $critical               = '14',
  $recurse                = true,
  $type                   = 'file',
  $number                 = '1',
  $has_parent             = false,
  $parent_host            = $nagios_alias,
  $parent_service         = '',
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service, $nagios_alias = $::hostname,) {
  require nagios::nrpe::config
  include nagios::nrpe::service
  require nagios::nrpe::checks::file_ages

  $recurse_string = $recurse ? {
    true  => '-r ',
    false => '',
  }
  $command = "command[check_file_ages_${directory}]=/usr/lib/nagios/plugins/check_file_ages.sh -w ${warning} ${recurse_string}-c ${critical} -t ${type} -d ${directory} -a ${number}"

  $service_description = "${nagios_alias}_check_file_ages_${directory}"

  file_line { "check_file_ages_${directory}":
    ensure => present,
    line   => $command,
    path   => '/etc/nagios/nrpe_local.cfg',
    match  => "command\[check_file_ages_${directory}\]",
    notify => Service[nrpe],
  }

  @@nagios_service { "check_file_ages_${directory}_on_${nagios_alias}":
    check_command       => "check_nrpe_1arg!check_file_ages_${directory}",
    use                 => $nagios_service,
    host_name           => $nagios_alias,
    target              => "/etc/nagios3/conf.d/puppet/service_${::fqdn}.cfg",
    service_description => "${nagios_alias}_check_file_ages_${directory}",
    tag                 => $monitoring_environment,
  }

  if $has_parent == true {
    @@nagios_servicedependency { "${directory}_file_age_on_${nagios_alias}_depencency_${parent_service}"
    :
      dependent_host_name           => $nagios_alias,
      dependent_service_description => $service_description,
      host_name => $parent_host,
      service_description           => $parent_service,
      execution_failure_criteria    => 'c',
      notification_failure_criteria => 'c',
      target    => "/etc/nagios3/conf.d/puppet/service_dependencies_${nagios_alias}.cfg",
      tag       => $monitoring_environment,
    }
  }

  @motd::register { "Nagios File Ages Check on ${directory}": }

}
