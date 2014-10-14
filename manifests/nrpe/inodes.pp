class nagios::nrpe::inodes ($nagios_service = $nagios::params::nagios_service) inherits nagios::params {
  require nagios::nrpe::config
  include nagios::nrpe::service

  $drive = split($::blockdevices, ",")

  nagios::nrpe::inodes::blockdevice_check { $drive: nagios_service => $nagios_service }

  define nagios::nrpe::inodes::blockdevice_check ($nagios_service = "generic_service") {
    if $name != "xvdd" and $name != "sr0" {
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
        use                 => "${nagios_service}",
        host_name           => $hostname,
        target              => "/etc/nagios3/conf.d/puppet/service_${fqdn}.cfg",
        service_description => "${hostname}_check_${drive}_inodes",
        tag                 => "${environment}",
      }

      @motd::register { "Nagios Inodes Check ${name}": }
    }

  }

  if $lvm == "true" {
    $excludedDrives = join(prefix($drive, "-I "), " ")

    file_line { "check_LVM_inodes":
      line   => "command[check_LVM_inodes]=/usr/lib/nagios/plugins/check_disk -W 15% -K 5% -p / ${excludedDrives}",
      path   => "/etc/nagios/nrpe_local.cfg",
      match  => "command\[check_LVM_inodes\]",
      ensure => present,
      notify => Service[nrpe],
    }

    @@nagios_service { "check_LVM_inodes_${hostname}":
      check_command       => "check_nrpe_1arg!check_LVM_inodes",
      use                 => "${nagios_service}",
      host_name           => $hostname,
      target              => "/etc/nagios3/conf.d/puppet/service_${fqdn}.cfg",
      service_description => "${hostname}_check_LVM_inodes",
      tag                 => "${environment}",
    }

    @motd::register { "Nagios Inodes Check LVM": }
  }

}
