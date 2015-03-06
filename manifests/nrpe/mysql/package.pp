class nagios::nrpe::mysql::package {
  package { 'percona-nagios-plugins': ensure => installed, }
}