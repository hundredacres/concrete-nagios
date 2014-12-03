# == Class: nagios::nrpe::checks::check_iostat
#
# A simple class, this will deploy the check_iostat script to the server and permission it correctly. This allows a
# define to be used as many times as you like for the nagios check itself, without any name/ duplicate decleration
# issues.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com
class nagios::nrpe::checks::iostat {
  file { 'check_iostat.sh':
    ensure => present,
    path   => '/usr/lib/nagios/plugins/check_iostat.sh',
    source => 'puppet:///modules/nagios/check_iostat.sh',
    owner  => 'nagios',
    group  => 'nagios',
    mode   => '0755',
  }
}