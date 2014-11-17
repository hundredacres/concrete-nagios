class nagios::nrpe::package {
  require stdlib
  include nagios::eventhandlers

  package { ["nagios-nrpe-server", "nagios-plugins-basic"]: ensure => installed, }

}
