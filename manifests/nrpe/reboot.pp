# Checks if a host needs to be rebooted as a result of updates.  The script checks for
# /var/run/reboot-required and raises a warning if present.

class nagios::nrpe::reboot ($nagios_service = $nagios::params::nagios_service) inherits nagios::params {
  require nagios::nrpe::config
  include nagios::nrpe::service

  file { "check_reboot.sh":
    path   => "/usr/lib/nagios/plugins/check_reboot.sh",
    source => "puppet:///modules/nagios/check_reboot.sh",
    owner  => root,
    group  => root,
    mode   => "0755",
    ensure => present,
    before => File_line[check_reboot],
  }

  file_line { "check_reboot":
    line   => "command[check_reboot]=/usr/lib/nagios/plugins/check_reboot.sh",
    path   => "/etc/nagios/nrpe_local.cfg",
    match  => "command\[check_reboot\]",
    ensure => present,
    notify => Service[nrpe],
  }

  @@nagios_service { "check_reboot_${hostname}":
    check_command       => "check_nrpe_1arg!check_reboot",
    use                 => "${nagios_service}",
    host_name           => $hostname,
    target              => "/etc/nagios3/conf.d/puppet/service_${fqdn}.cfg",
    service_description => "${hostname}_check_reboot",
    tag                 => "${environment}",
    notifications_enabled => 0,
  }

  @motd::register { 'Nagios Reboot Check': }

}
