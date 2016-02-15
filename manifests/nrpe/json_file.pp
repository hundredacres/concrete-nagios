# == Define: nagios::nrpe::json_file
#
# This class will allow us to check the value of a variable in a json file on
# the server. This could be useful for creating checks where a service provides
# a json file as an output
#
# === Parameters
#
# [*namevar*]
#   The directory will default to the name of the resource. This is the
#   directory that the file count will be run on.
#
# [*variable*]
#   The variable in the json file to check
#   Required.
#
# [*extra_variable*]
#   The variable that will be returned in the nagios return but not tested. Used
#   for extra detail.
#   Not required. Defaults to none.
#
# [*warning*]
#   The warning level. It will warn if the variable is below this value. This is
#   only used if critical is used.
#   Not required. Defaults to none.
#
# [*crtical*]
#   The critical level. It will be critical if the variable is below this value.
#   This can only be used if pass is NOT used.
#   Not required. Defaults to none.
#
# [*pass*]
#   The value to check for. It will be critical if the variable not this value.
#   This can only be used if critical is NOT used.
#   Not required. Defaults to none.
#
# === Variables
#
# [*command*]
#   This is the command that nrpe will use to check the json.
#
# === Examples
#
#  nagios::nrpe::json_file { "/opt/test.json":
#    variable => "status"
#    pass     => "OK"
#  }
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com>
define nagios::nrpe::json_file (
  $variable,
  $json_file              = $name,
  $extra_variable         = '',
  $warning                = '',
  $critical               = '',
  $pass                   = '',
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $nagios_alias           = $::hostname,) {
  require nagios::nrpe::config
  include nagios::nrpe::service
  require nagios::nrpe::checks::json_file

  if $critical == '' and $pass == '' or $critical != '' and $pass != '' {
    err('Must have one and only one of critical or pass')
  }

  $command_name = "check_json_file_${json_file}_${variable}"

  if $critical != '' {
    if $warning == '' {
      $command = "command[${command_name}]=/usr/lib/nagios/plugins/check_json_file.py -f ${json_file} -v ${variable} -c ${critical}"
    } else {
      $command = "command[${command_name}]=/usr/lib/nagios/plugins/check_json_file.py -f ${json_file} -v ${variable} -w ${warning} -c ${critical}"
    }
  } else {
    if $extra_variable == '' {
      $command = "command[${command_name}]=/usr/lib/nagios/plugins/check_json_file.py -f ${json_file} -v ${variable} -p ${pass}"
    } else {
      $command = "command[${command_name}]=/usr/lib/nagios/plugins/check_json_file.py -f ${json_file} -v ${variable} -x ${extra_variable} -p ${pass}"
    }
  }

  file_line { $command_name:
    ensure => present,
    line   => $command,
    path   => '/etc/nagios/nrpe_local.cfg',
    match  => "command\[${command_name}\]",
    notify => Service[nrpe],
  }

  @@nagios_service { "${command_name}_on_${nagios_alias}":
    check_command       => "check_nrpe_1arg!${command_name}",
    use                 => $nagios_service,
    host_name           => $nagios_alias,
    target              => "/etc/nagios/conf.d/puppet/service_${nagios_alias}.cfg",
    service_description => "${nagios_alias}_${command_name}",
    tag                 => $monitoring_environment,
  }
}
