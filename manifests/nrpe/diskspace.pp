# Use the default diskspace check (warn on 20%, critical on 10%). I believe this automatically checks sysvol.

class nagios::nrpe::diskspace {
  require nagios::nrpe::config
  include nagios::nrpe::service

  file_line { "check_root_diskspace":
    line   => "command[check_root_diskspace]=/usr/lib/nagios/plugins/check_disk -w 20% -c 10% -p /",
    path   => "/etc/nagios/nrpe_local.cfg",
    match  => "command\[check_root_diskspace\]",
    ensure => present,
    before => File_line[check_disk_default],
    notify => Service[nrpe],
  }

  file_line { "check_disk_default":
    line   => "command[check_disk]=/usr/lib/nagios/plugins/check_disk -w 20% -c 10% -p /",
    path   => "/etc/nagios/nrpe.cfg",
    match  => "command\[check_disk\]",
    ensure => absent,
    notify => Service[nrpe],
  }

  @@nagios_service { "check_sysvol_space_${hostname}":
    check_command       => "check_nrpe_1arg!check_root_diskspace",
    use                 => "generic-service",
    host_name           => $hostname,
    target              => "/etc/nagios3/conf.d/puppet/service_${fqdn}.cfg",
    service_description => "${hostname}_check_sysvol_space",
    tag                 => "${environment}",
  }

  @basic_server::motd::register { 'Nagios Diskspace Check': }

}

