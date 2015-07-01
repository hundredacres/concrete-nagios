class nagios::nrpe::mysql::replication_delay (
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $alias                  = $::hostname) {
  require nagios::nrpe::config
  include nagios::nrpe::service
  require nagios::nrpe::mysql::package

  file_line { 'check_replication_delay':
    ensure => present,
    line   => "command[check_replication_delay]=/usr/lib64/nagios/plugins/pmp-check-mysql-replication-delay -w 60 -c 300",
    path   => '/etc/nagios/nrpe_local.cfg',
    match  => 'command\[check_replication_delay\]',
    notify => Service['nrpe'],
  }

  @@nagios_service { "check_replication_delay_${alias}":
    check_command       => 'check_nrpe_1arg!check_replication_delay',
    use                 => $nagios_service,
    host_name           => $alias,
    target              => "/etc/nagios3/conf.d/puppet/service_${::fqdn}.cfg",
    service_description => "${alias}_check_replication_delay",
    tag                 => $monitoring_environment,
  }

  @motd::register { 'Nagios Mysql Replication Delay Check': }
}
