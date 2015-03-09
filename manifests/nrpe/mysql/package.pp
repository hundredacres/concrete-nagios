class nagios::nrpe::mysql::package {
  require base::apt::repo::percona
  
  package { 'percona-nagios-plugins': ensure => installed, }
}