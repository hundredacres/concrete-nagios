class nagios::nrpe::service {
  service { nagios-nrpe-server:
    alias   => "nrpe",
    ensure  => running,
    enable  => true,
    require => Package[nagios-nrpe-server],
  }

}
