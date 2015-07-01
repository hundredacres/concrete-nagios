class nagios::nrpe::mysql::quorum (
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $alias                  = $::hostname) {
  require nagios::nrpe::config
  include nagios::nrpe::service
  require nagios::nrpe::mysql::package

  file_line { 'check_quorum_status':
    ensure => present,
    line   => "command[check_quorum_status]=/usr/lib64/nagios/plugins/pmp-check-mysql-status -x wsrep_cluster_status -C == -T str -c non-Primary",
    path   => '/etc/nagios/nrpe_local.cfg',
    match  => 'command\[check_quorum_status\]',
    notify => Service['nrpe'],
  }

  @@nagios_service { "check_quorum_status_${alias}":
    check_command       => 'check_nrpe_1arg!check_quorum_status',
    use                 => $nagios_service,
    host_name           => $alias,
    target              => "/etc/nagios3/conf.d/puppet/service_${::fqdn}.cfg",
    service_description => "${alias}_check_quorum_status",
    tag                 => $monitoring_environment,
  }

  @motd::register { 'Nagios Mysql Quorum Check': }
}
