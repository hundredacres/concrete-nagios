# == Class: nagios::nrpe::checks::recent_files
#
# A simple class, this will deploy the check_recent_files script to the server and
# permission it correctly. This allows a define to be used as many times as you
# like for the nagios check itself, without any name/ duplicate decleration
# issues.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com>
# Julien Simon <julien.simon@concreteplatform.com>
class nagios::nrpe::checks::recent_files {
  require nagios::nrpe::config
  
  file { 'check_recent_files.sh':
    ensure => present,
    path   => '/usr/lib/nagios/plugins/check_recent_files.sh',
    source => 'puppet:///modules/nagios/check_recent_files.sh',
    owner  => 'nagios',
    group  => 'nagios',
    mode   => '0755',
  }
}
