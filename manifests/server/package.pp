class nagios::server::package {
  include nagios::eventhandlers
  
  package { nagios3: ensure => installed,; }

}
