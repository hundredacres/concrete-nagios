# == Define: nagios::nrpe::process
#
# This will build a nagios check for the process specified. This will handle the configuration both client and server side.
# It will also allow you to use an event handler with the restart command specified, and will allow you to decide whether
# this command should be added to the sudoers file for the nagios user.
#
# === Parameters
#
# [*process*]
#   The name of the process you would like to test:
# 	Uses -C from https://www.monitoring-plugins.org/doc/man/check_procs.html
#   Required. Note: Not currently tested.
#
# [*warning_low*]
#   The low bound of the process count, for warning level
# 	Uses -w from https://www.monitoring-plugins.org/doc/man/check_procs.html
# 	Defaults to 1. Not required.
#
# [*critical_low*]
#   The low bound of the process count, for critical level
# 	Uses -c from https://www.monitoring-plugins.org/doc/man/check_procs.html
# 	Defaults to 1. Not required.
#
# [*warning_high*]
#   The high bound of the process count, for warning level
# 	Uses -w from https://www.monitoring-plugins.org/doc/man/check_procs.html
#   Defaults to "". Not required.
#
# [*critical_high*]
#   The high bound of the process count, for critical level
# 	Uses -c from https://www.monitoring-plugins.org/doc/man/check_procs.html
#   Defaults to "". Not required
#
# [*event_handler*]
# 	A boolean value. Whether or not you would like to trigger an event_handler on
#   service failure. This will run the restart_command you specified on detecting a failure.
#   Defaults to false. Not required.
#
# [*restart_command*]
# 	The command you wish to run on service failure. Typically a restart command.
# 	Do not add use sudo in the command, sudo_required will do this automatically
#   for you.
#   Defaults to "/etc/init.d/$process restart". Not required.
#
# [*sudo_required*]
# 	Whether the restart command requires do. If true, will add nagios user to the sudoers file for that command,
#  	as well as adding it to the command the event handler will run.
#   Defaults to true. Not required.
#
# === Examples
#
# To check the nginx process and restart if down:
#
#   nagios::nrpe::process { "${hostname} nginx process":
#    process         => "nginx",
#    warning_low         => $warningprocesses,
#    critical_low        => "1",
#    event_handler   => true,
#    restart_command => "/etc/init.d/nginx restart",
#    sudo_required   => true
#  }
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com
#
define nagios::nrpe::process (
  $process         = "",
  $warning_low     = "1",
  $critical_low    = "1",
  $warning_high    = "",
  $critical_high   = "",
  $event_handler   = false,
  $restart_command = "",
  $sudo_required   = true) {
  require nagios::nrpe::config
  include nagios::nrpe::service
  include nagios::params

  $nagios_service = $::nagios::params::nagios_service

  if $restart_command == "" and $event_handler == true {
    $restart_command = "/etc/init.d/${process} restart"
  }

  file_line { "check_${process}_processes":
    line   => "command[check_${process}_processes]=/usr/lib/nagios/plugins/check_procs -w ${warning_low}:${warning_high} -c ${critical_low}:${critical_high} -C ${process}",
    path   => "/etc/nagios/nrpe_local.cfg",
    match  => "command\[check_${process}_processes\]",
    ensure => present,
    notify => Service[nrpe],
  }

  if $event_handler == true {
    if $sudo_required == true {
      # add nagios to sudoers so it can run $restart_command}
      file_line { "${process}_sudoers":
        line   => "nagios ALL=(ALL) NOPASSWD: ${restart_command}",
        path   => "/etc/sudoers",
        ensure => present,
        before => File_line["restart_${process}"],
      }

      $final_restart_command = "sudo ${restart_command}"
    } else {
      $final_restart_command = $restart_command
    }

    file { "restart_${process}.sh":
      path    => "/usr/lib/nagios/eventhandlers/restart_${process}.sh",
      content => template('nagios/restart_service.conf.erb'),
      owner   => nagios,
      group   => nagios,
      mode    => "0755",
      ensure  => present,
      before  => File_line["restart_${process}"],
      require => File["/usr/lib/nagios/eventhandlers"],
    }

    file_line { "restart_${process}":
      line   => "command[restart_${process}]=/usr/lib/nagios/eventhandlers/restart_${process}.sh",
      path   => "/etc/nagios/nrpe_local.cfg",
      ensure => present,
      notify => Service[nrpe],
    }

    @@nagios_service { "check_${process}_processes_${hostname}":
      check_command       => "check_nrpe_1arg!check_${process}_processes",
      use                 => "${nagios_service}",
      host_name           => $hostname,
      target              => "/etc/nagios3/conf.d/puppet/service_${fqdn}.cfg",
      service_description => "${hostname}_check_${process}_processes",
      tag                 => "${environment}",
      event_handler       => "event_handler!restart_${process}",
    }

    @motd::register { "${process} Nagios Check and Restart script": }

  } else {
    @@nagios_service { "check_${process}_processes_${hostname}":
      check_command       => "check_nrpe_1arg!check_${process}_processes",
      use                 => "${nagios_service}",
      host_name           => $hostname,
      target              => "/etc/nagios3/conf.d/puppet/service_${fqdn}.cfg",
      service_description => "${hostname}_check_${process}_processes",
      tag                 => "${environment}",
    }

    @motd::register { "${process} Nagios Check": }
  }

}