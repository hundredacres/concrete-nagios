class nagios::nrpe::mysql::flow_control {
  require nagios::nrpe::config
  include nagios::nrpe::service
  include nagios::params
  require nagios::nrpe::mysql::package
  require nagios::nrpe::mysql::user

  $nagios_service = $::nagios::params::nagios_service

  include basic_server::params

  $monitoring_environment = $::basic_server::params::monitoring_environment

  file_line { 'check_flow_control':
    ensure => present,
    line   => "command[check_flow_control]=/usr/lib64/nagios/plugins/pmp-check-mysql-status -x wsrep_flow_control_paused -w 0.1 -c 0.9",
    path   => '/etc/nagios/nrpe_local.cfg',
    match  => 'command\[check_flow_control\]',
    notify => Service['nrpe'],
  }

  @@nagios_service { "check_flow_control_${::hostname}":
    check_command       => 'check_nrpe_1arg!check_flow_control',
    use                 => $nagios_service,
    host_name           => $::hostname,
    target              => "/etc/nagios3/conf.d/puppet/service_${::fqdn}.cfg",
    service_description => "${::hostname}_check_flow_control",
    tag                 => $monitoring_environment,
  }

  @motd::register { 'Nagios Mysql Flow Control Check': }
}