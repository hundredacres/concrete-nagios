class nagios::nrpe::mysql::file_privs (
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $nagios_alias           = $::hostname) {
  require nagios::nrpe::config
  include nagios::nrpe::service
  require nagios::nrpe::mysql::package

  file_line { 'check_file_privs':
    ensure => present,
    line   => 'command[check_file_privs]=/usr/lib64/nagios/plugins/pmp-check-mysql-file-privs',
    path   => '/etc/nagios/nrpe_local.cfg',
    match  => 'command\[check_file_privs\]',
    notify => Service['nrpe'],
  }

  @@nagios_service { "check_file_privs_${nagios_alias}":
    check_command       => 'check_nrpe_1arg!check_file_privs',
    use                 => $nagios_service,
    host_name           => $nagios_alias,
    target              => "/etc/nagios3/conf.d/puppet/service_${nagios_alias}.cfg",
    service_description => "${nagios_alias}_check_file_privs",
    tag                 => $monitoring_environment,
  }

  @motd::register { 'Nagios Mysql File Privs Check': }
}