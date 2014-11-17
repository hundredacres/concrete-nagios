class nagios::nrpe::package {
  require stdlib

  package { ["nagios-nrpe-server", "nagios-plugins-basic"]: ensure => installed, }

  file { "/usr/lib/nagios/eventhandlers":
    ensure  => directory,
    recurse => true,
    owner   => nagios,
    group   => nagios,
    mode    => 755,
  }

}
