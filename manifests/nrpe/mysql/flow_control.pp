class nagios::nrpe::mysql::flow_control (
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $alias                  = $::hostname) {
  require nagios::nrpe::config
  include nagios::nrpe::service
  require nagios::nrpe::mysql::package

  file_line { 'check_flow_control':
    ensure => present,
    line   => "command[check_flow_control]=/usr/lib64/nagios/plugins/pmp-check-mysql-status -x wsrep_flow_control_paused -w 0.1 -c 0.9",
    path   => '/etc/nagios/nrpe_local.cfg',
    match  => 'command\[check_flow_control\]',
    notify => Service['nrpe'],
  }

  @@nagios_service { "check_flow_control_${alias}":
    check_command       => 'check_nrpe_1arg!check_flow_control',
    use                 => $nagios_service,
    host_name           => $alias,
    target              => "/etc/nagios3/conf.d/puppet/service_${::fqdn}.cfg",
    service_description => "${alias}_check_flow_control",
    tag                 => $monitoring_environment,
  }

  @motd::register { 'Nagios Mysql Flow Control Check': }
}
