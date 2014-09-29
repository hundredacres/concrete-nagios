class nagios::nrpe::inodes {
  require nagios::nrpe::config
  include nagios::nrpe::service

  $drive = split($::blockdevices, ",")

  nagios::nrpe::inodes::blockdevice_check { $drive: }

  define nagios::nrpe::inodes::blockdevice_check {
    if $name != "xvdd" or $name != "sr0" {
      file_line { "check_${name}_inodes":
        line   => "command[check_${name}_inodes]=/usr/lib/nagios/plugins/check_disk -E -W 15% -K 5% -R /dev/${name}*",
        path   => "/etc/nagios/nrpe_local.cfg",
        match  => "command\[check_${name}_inodes\]",
        ensure => present,
        notify => Service[nrpe],
      }

      # For neatness :

      if $name == "xvda" {
        $drive = "sysvol"
      } else {
        $drive = $name
      }

      @@nagios_service { "check_${drive}_inodes_${hostname}":
        check_command       => "check_nrpe_1arg!check_${name}_inodes",
        use                 => "generic-service",
        host_name           => $hostname,
        target              => "/etc/nagios3/conf.d/puppet/service_${fqdn}.cfg",
        service_description => "${hostname}_check_${drive}_inodes",
        tag                 => "${environment}",
      }

      @basic_server::motd::register { "Nagios Inodes Check ${name}": }
    }

  }

}
