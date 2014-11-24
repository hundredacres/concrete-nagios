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

  nagios::nrpe::blockdevice::diskspace { $drive:
    require        => File_Line["check_disk_default"],
  }

  if $lvm == "true" {
    $excludedDrives = join(prefix($drive, "-I "), " ")

    file_line { "check_LVM_diskspace":
      line   => "command[check_LVM_diskspace]=/usr/lib/nagios/plugins/check_disk -w 20% -c 10% -p / ${excludedDrives}",
      path   => "/etc/nagios/nrpe_local.cfg",
      match  => "command\[check_LVM_diskspace\]",
      ensure => present,
      notify => Service[nrpe],
    }

    @@nagios_service { "check_LVM_space_${hostname}":
      check_command       => "check_nrpe_1arg!check_LVM_diskspace",
      use                 => "${nagios_service}",
      host_name           => $hostname,
      target              => "/etc/nagios3/conf.d/puppet/service_${fqdn}.cfg",
      service_description => "${hostname}_check_LVM_space",
      tag                 => "${environment}",
    }

    @motd::register { "Nagios Diskspace Check LVM": }
  }
}

