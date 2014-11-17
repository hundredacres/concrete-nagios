define nagios::nrpe::process (
  $process         = "",
  $warning         = "2",
  $critical        = "1",
  $event_handler   = false,
  $restart_command = "",
  $sudo_required   = true) {
  require nagios::nrpe::config
  include nagios::nrpe::service
  include nagios::params

  $nagios_service = $::nagios::params::nagios_service

  if $restart_command = "" {
    $restart_command = "/etc/init.d/${process} restart"
  }

  file_line { "check_${process}_processes":
    line   => "command[check_${process}_processes]=/usr/lib/nagios/plugins/check_procs -w ${warning}: -c ${critical}: -C ${process}",
    path   => "/etc/nagios/nrpe_local.cfg",
    match  => "command\[check_${process}_processes\]",
    ensure => present,
    notify => Service[nrpe],
  }

  if $event_handler == true {
    if $sudo_required == true {
      # add nagios to sudoers so it can run $restart_command}
      file_line { "nginx_sudoers":
        line   => "nagios ALL=(ALL) NOPASSWD: ${restart_command}",
        path   => "/etc/sudoers",
        ensure => present,
        before => File_line["restart_nginx"],
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
      event_handler       => "restart_${process}",
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