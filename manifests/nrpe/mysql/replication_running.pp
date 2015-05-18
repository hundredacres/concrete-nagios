class nagios::nrpe::mysql::replication_running {
  require nagios::nrpe::config
  include nagios::nrpe::service
  include nagios::params
  require nagios::nrpe::mysql::package
  require nagios::nrpe::mysql::user

  $nagios_service = $::nagios::params::nagios_service

  include base::params

  $monitoring_environment = $::base::params::monitoring_environment

  file_line { 'check_replication_running':
    ensure => present,
    line   => "command[check_replication_running]=/usr/lib64/nagios/plugins/pmp-check-mysql-replication-running -w 0 -c 0",
    path   => '/etc/nagios/nrpe_local.cfg',
    match  => 'command\[check_replication_running\]',
    notify => Service['nrpe'],
  }

  @@nagios_service { "check_replication_running_${::hostname}":
    check_command       => 'check_nrpe_1arg!check_replication_running',
    use                 => $nagios_service,
    host_name           => $::hostname,
    target              => "/etc/nagios3/conf.d/puppet/service_${::fqdn}.cfg",
    service_description => "${::hostname}_check_replication_running",
    tag                 => $monitoring_environment,
  }

  @motd::register { 'Nagios Mysql Replication Running Check': }
}
