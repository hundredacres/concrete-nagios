class nagios::nrpe::mysql::quorum ($nagios_password) {
  require nagios::nrpe::config
  include nagios::nrpe::service
  include nagios::params
  require nagios::nrpe::mysql::package

  $nagios_service = $::nagios::params::nagios_service

  include basic_server::params

  $monitoring_environment = $::basic_server::params::monitoring_environment

  file_line { 'check_quorum_status':
    ensure => present,
    line   => "command[check_quorum_status]=/usr/lib64/nagios/plugins/pmp-check-mysql-status -l nagios -p ${nagios_password} -x wsrep_cluster_status -C == -T str -c non-Primary",
    path   => '/etc/nagios/nrpe_local.cfg',
    match  => 'command\[check_quorum_status\]',
    notify => Service['nrpe'],
  }

  @@nagios_service { "check_quorum_status_${::hostname}":
    check_command       => 'check_nrpe_1arg!check_quorum_status',
    use                 => $nagios_service,
    host_name           => $::hostname,
    target              => "/etc/nagios3/conf.d/puppet/service_${::fqdn}.cfg",
    service_description => "${::hostname}_check_quorum_status",
    tag                 => $monitoring_environment,
  }

  @motd::register { 'Nagios Mysql Quorum Check': }
}