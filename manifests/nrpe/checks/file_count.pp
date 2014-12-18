# == Class: nagios::nrpe::checks::file_count
#
# A simple class, this will deploy the check_file_count script to the server and
# permission it correctly. This allows a define to be used as many times as you
# like for the nagios check itself, without any name/ duplicate decleration
# issues.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com
class nagios::nrpe::checks::file_count {
  file { 'check_file_count.sh':
    ensure => present,
    path   => '/usr/lib/nagios/plugins/check_file_count.sh',
    source => 'puppet:///modules/nagios/check_file_count.sh',
    owner  => 'nagios',
    group  => 'nagios',
    mode   => '0755',
  }
}
