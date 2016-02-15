# == Class: nagios::nrpe::checks::json_file
#
# A simple class, this will deploy the check_json_file script to the server and
# permission it correctly. This allows a define to be used as many times as you
# like for the nagios check itself, without any name/ duplicate decleration
# issues.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com>
class nagios::nrpe::checks::json_file {
  require nagios::nrpe::config

  file { 'check_json_file.py':
    ensure => present,
    path   => '/usr/lib/nagios/plugins/check_json_file.py',
    source => 'puppet:///modules/nagios/nrpe/checks/check_json_file.py',
    owner  => 'nagios',
    group  => 'nagios',
    mode   => '0755',
  }
}