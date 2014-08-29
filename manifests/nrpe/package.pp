class nagios::nrpe::package {
  require stdlib

  package { ["nagios-nrpe-server", "nagios-plugins-basic"]: ensure => installed, }

}
