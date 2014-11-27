class nagios::nrpe::inodes {
  require nagios::nrpe::config
  include nagios::nrpe::service
  include nagios::params

  $nagios_service = $::nagios::params::nagios_service

  $drive = split($::blockdevices, ",")

  nagios::nrpe::blockdevice::inodes { $drive: }

  if $::lvm == "true" {
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
