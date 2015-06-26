class nagios::nrpe::mysql::deleted_files (
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service) {
  require nagios::nrpe::config
  include nagios::nrpe::service
  require nagios::nrpe::mysql::package

  file_line { 'check_deleted_files':
    ensure => present,
    line   => 'command[check_deleted_files]=/usr/lib64/nagios/plugins/pmp-check-mysql-deleted-files',
    path   => '/etc/nagios/nrpe_local.cfg',
    match  => 'command\[check_deleted_files\]',
    notify => Service['nrpe'],
  }

  @@nagios_service { "check_deleted_files_${::hostname}":
    check_command       => 'check_nrpe_1arg!check_deleted_files',
    use                 => $nagios_service,
    host_name           => $::hostname,
    target              => "/etc/nagios3/conf.d/puppet/service_${::fqdn}.cfg",
    service_description => "${::hostname}_check_deleted_files",
    tag                 => $monitoring_environment,
  }

  @motd::register { 'Nagios Mysql Deleted Files Check': }
}