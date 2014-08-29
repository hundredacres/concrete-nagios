# Uses a simple check mem script from nagios exchange (could potentially do with cleaning up). Will warn if less than 15% memory,
# critical on 5%.

class nagios::nrpe::memory {
  require nagios::nrpe::config
  include nagios::nrpe::service

  file { "check_mem.sh":
    path   => "/usr/lib/nagios/plugins/check_mem.sh",
    source => "puppet:///modules/nagios/check_mem.sh",
    owner  => root,
    group  => root,
    mode   => "0755",
    ensure => present,
    before => File_line[check_mem],
  }

  file_line { "check_mem":
    line   => "command[check_mem]=/usr/lib/nagios/plugins/check_mem.sh -w 85 -c 95",
    path   => "/etc/nagios/nrpe_local.cfg",
    match  => "command\[check_mem\]",
    ensure => present,
    notify => Service[nrpe],
  }

  @@nagios_service { "check_memory_${hostname}":
    check_command       => "check_nrpe_1arg!check_mem",
    use                 => "generic-service",
    host_name           => $hostname,
    target              => "/etc/nagios3/conf.d/puppet/service_${fqdn}.cfg",
    service_description => "${hostname}_check_memory",
    tag                 => "${environment}",
  }

  motd::register { 'Nagios Memory Check': }

}
