class nagios::nrpe::config (
  $server = $nagios::params::server
  ) inherits nagios::params
  {
  
  require nagios::nrpe::package
  include nagios::nrpe::service
  
  $hosts = "allowed_hosts = 127.0.0.1,$server"
  
  file_line { "allowed_hosts":
    line   => $hosts,
    path   => "/etc/nagios/nrpe.cfg",
    match  => "^allowed_hosts",
    ensure => present,
    notify => Service[nrpe],
  }

  @motd::register { 'NRPE End Point': }

}
