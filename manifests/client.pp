class nagios::client {
  @@nagios_host { $hostname:
    target  => "/etc/nagios3/conf.d/puppet/host_${fqdn}.cfg",
    ensure  => present,
    address => $ipaddress,
    use     => "generic-host",
    alias   => $hostname,
    tag     => "${environment}",
  }

  @@nagios_service { "check_ping_${hostname}":
    target              => "/etc/nagios3/conf.d/puppet/service_${fqdn}.cfg",
    check_command       => "check_ping!100.0,20%!500.0,60%",
    use                 => "generic-service",
    host_name           => "$hostname",
    notification_period => "24x7",
    service_description => "${hostname}_check_ping",
    require             => nagios_host[$hostname],
    tag                 => "${environment}",
  }

  motd::register { 'Nagios Host Check': }

}
