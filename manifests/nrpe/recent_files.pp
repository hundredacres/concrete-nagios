# == Define: nagios::nrpe::recent_files
#
# This class will allow us to check the presence of files in a folder, with an age
# below a certain level, is above a certain threshold. This is useful for
# checking that a process is correctly running (example backup). We could
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
# [*extension*]
#   The type of file to check for (file, directory or both).
#   Not require. Defaults to file.
#
#
# [*monitoring_environment*]
#   This is the environment that the check will be submitted for. This will
#   default to the value set by nagios::nrpe::config but can be overridden here.
#   Not required.
#
# [*nagios_service*]
#   This is the generic service that this check will implement. This should
#   be set by nagios::nrpe::config but can be overridden here. Not required.
#
# [*nagios_alias*]
#   This is the hostname that the check will be submitted for. This should
#   almost always be the hostname, but could be overriden, for instance when
#   submitting a check for a virtual ip. Not required.
#
# === Variables
#
# [*command*]
#   This is the command that nrpe will use to check the file count.
#
# === Examples
#
#  nagios::nrpe::recent_files { "/var/www/repo/apt/incoming":
#    warning  => "7",
#    critical => "14",
#    etxtension  => "bak",
#  }
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com>
# Julien Simon <julien.simon@concreteplatform.com>
define nagios::nrpe::recent_files (
  $directory              = $name,
  $warning                = '2',
  $critical               = '1',
  $extension              = 'bak',
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $nagios_alias           = $::hostname,) {
  require nagios::nrpe::config
  include nagios::nrpe::service
  require nagios::nrpe::checks::recent_files

  $directory = regsubst($directory, '(/|-)', '_', 'G')
  
  $command = "command[check_recent_files_${directory}_${extension}]=/usr/lib/nagios/plugins/check_recent_files.sh -w ${warning} -c ${critical} -d ${directory} -t ${extension}"

  $service_description = "${nagios_alias}_check_recent_files_${directory}_${extension}"

  file_line { "check_recent_files_${directory}_${extension}":
    ensure => present,
    line   => $command,
    path   => '/etc/nagios/nrpe_local.cfg',
    match  => "command\[check_recent_files_${directory}_${extension}\]",
    notify => Service[nrpe],
  }

  @@nagios_service { "check_recent_files_${directory}_${extension}_on_${nagios_alias}":
    check_command       => "check_nrpe_1arg!check_recent_files_${directory}_${extension}",
    use                 => $nagios_service,
    host_name           => $nagios_alias,
    target              => "/etc/nagios3/conf.d/puppet/service_${::fqdn}.cfg",
    service_description => "${nagios_alias}_check_recent_files_${directory}_${extension}",
    tag                 => $monitoring_environment,
  }

}
