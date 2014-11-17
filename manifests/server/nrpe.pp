class nagios::server::nrpe {
  require nagios::server::config
  include nagios::server::service

  package { "nagios-nrpe-plugin":
    ensure => installed,
    notify => Service[nagios3],
  }

  @motd::register { 'Nagios NRPE Server': }

}
