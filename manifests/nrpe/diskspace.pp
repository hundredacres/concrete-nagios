# Use the default diskspace check (warn on 20%, critical on 10%). I believe this automatically checks sysvol.

class nagios::nrpe::diskspace {
  require nagios::nrpe::config
  include nagios::nrpe::service

  # Remove the default check_disk

  file_line { "check_disk_default":
    line   => "command[check_disk]=/usr/lib/nagios/plugins/check_disk -w 20% -c 10% -p /",
    path   => "/etc/nagios/nrpe.cfg",
    match  => "command\[check_disk\]",
    ensure => absent,
    notify => Service[nrpe],
  }

  $drive = split($::blockdevices, ",")

  nagios::nrpe::diskspace::blockdevice_check { $drive: require => File_Line["check_disk_default"], }

  define nagios::nrpe::diskspace::blockdevice_check {
    if $name != "xvdd" {
      file_line { "check_${name}_diskspace":
        line   => "command[check_${name}_diskspace]=/usr/lib/nagios/plugins/check_disk -E -w 20% -c 10% -R /dev/${name}*",
        path   => "/etc/nagios/nrpe_local.cfg",
        match  => "command\[check_${name}_diskspace\]",
        ensure => present,
        notify => Service[nrpe],
      }

      # For neatness :

      if $name == "xvda" {
        $drive = "sysvol"
      } else {
        $drive = $name
      }

      @@nagios_service { "check_${drive}_space_${hostname}":
        check_command       => "check_nrpe_1arg!check_${name}_diskspace",
        use                 => "generic-service",
        host_name           => $hostname,
        target              => "/etc/nagios3/conf.d/puppet/service_${fqdn}.cfg",
        service_description => "${hostname}_check_${drive}_space",
        tag                 => "${environment}",
      }

      @basic_server::motd::register { "Nagios Diskspace Check $name": }

    }

  }
}

