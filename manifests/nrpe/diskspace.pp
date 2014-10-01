# Use the default diskspace check (warn on 20%, critical on 10%). I believe this automatically checks sysvol.

class nagios::nrpe::diskspace ($nagios_service = $nagios::params::nagios_service) inherits nagios::params {
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

  nagios::nrpe::diskspace::blockdevice_check { $drive:
    require        => File_Line["check_disk_default"],
    nagios_service => $nagios_service
  }

  define nagios::nrpe::diskspace::blockdevice_check ($nagios_service = "generic_service") {
    if $name != "xvdd" and $name != "sr0" {
      # Going to have a different check for very large disks ( gt than 100GB)

      $size = getvar("blockdevice_${name}_size")

      if $size > 100 * 1024 * 1024 * 1024 {
        $warning = "10"
        $critical = "5"
      } else {
        $warning = "20"
        $critical = "10"
      }

      file_line { "check_${name}_diskspace":
        line   => "command[check_${name}_diskspace]=/usr/lib/nagios/plugins/check_disk -E -w ${warning}% -c ${critical}% -R /dev/${name}*",
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
        use                 => "${nagios_service}",
        host_name           => $hostname,
        target              => "/etc/nagios3/conf.d/puppet/service_${fqdn}.cfg",
        service_description => "${hostname}_check_${drive}_space",
        tag                 => "${environment}",
      }

      @basic_server::motd::register { "Nagios Diskspace Check $name": }

    }

  }

	notify{ ${lvm}:}

  if ${lvm} == true or ${hostname} == "bendev" {
    $excludedDrives = join(prefix(${drive}, "-I "), " ")

    file_line { "check_lvm_diskspace":
      line   => "command[check_lvm_diskspace]=/usr/lib/nagios/plugins/check_disk -w 20% -c 10% -p / ${excludedDrives}",
      path   => "/etc/nagios/nrpe_local.cfg",
      match  => "command\[check_lvm_diskspace\]",
      ensure => present,
      notify => Service[nrpe],
    }

    @@nagios_service { "check_lvm_space_${hostname}":
      check_command       => "check_nrpe_1arg!check_lvm_diskspace",
      use                 => "${nagios_service}",
      host_name           => $hostname,
      target              => "/etc/nagios3/conf.d/puppet/service_${fqdn}.cfg",
      service_description => "${hostname}_check_lvm_space",
      tag                 => "${environment}",
    }
  }
}

