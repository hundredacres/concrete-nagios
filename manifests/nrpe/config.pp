class nagios::nrpe::config {
  require nagios::nrpe::package
  include nagios::nrpe::service

  # look to replace this with heira when we have more time for it:

  case $::environment {
    'testing'     : { $hosts = "allowed_hosts = 127.0.0.1,192.168.90.223" }
    'development' : { $hosts = "allowed_hosts = 127.0.0.1,192.168.90.99" }
    default       : { $hosts = "allowed_hosts = 127.0.0.1,192.168.90.223" }
  }

  file_line { "allowed_hosts":
    line   => $hosts,
    path   => "/etc/nagios/nrpe.cfg",
    match  => "allowed_hosts",
    ensure => present,
    notify => Service[nrpe],
  }

  motd::register { 'NRPE End Point': }

}
