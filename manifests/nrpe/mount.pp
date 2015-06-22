define nagios::nrpe::mount (
  $mount_path             = $name,
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service) {
  require nagios::nrpe::config
  include nagios::nrpe::service
  require nagios::nrpe::checks::mount

  file_line { "check_mount_${mount_path}":
    ensure => present,
    line   => "command[check_mount_${mount_path}]=/usr/lib/nagios/plugins/check_mount.sh -p ${mount_path}",
    path   => '/etc/nagios/nrpe_local.cfg',
    match  => "command\[check_mount_${mount_path}\]",
    notify => Service[nrpe],
  }

  @@nagios_service { "check_mount_${mount_path}_on_${::hostname}":
    check_command       => "check_nrpe_1arg!check_mount_${mount_path}",
    use                 => $nagios_service,
    host_name           => $::hostname,
    target              => "/etc/nagios3/conf.d/puppet/service_${::fqdn}.cfg",
    service_description => "${::hostname}_check_mount_${mount_path}",
    tag                 => $monitoring_environment,
  }

  @motd::register { "Nagios Mount Check on ${mount_path}": }
}
