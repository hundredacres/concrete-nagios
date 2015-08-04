# == Define: nagios::nrpe::mysql::package
#
# This is going install the percona mysql plugins for the other mysql checks and
# also add the nagios user to the mysql group which is needed for most of the
# checks.
#
# Note: Most of these checks will need a nagios mysql user with credentials at
# /etc/nagios/mysql.cnf
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com>
class nagios::nrpe::mysql::package {
  require base::apt::repo::percona

  package { 'percona-nagios-plugins': ensure => installed, }

  user { 'nagios': groups => ['mysql'], }
}