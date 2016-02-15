# == Class: nagios::server::nessus_reports
#
# This is going to set up a plugin and command to be able to test nessus reports
# for warning and critical levels of incidents.
#
# === Parameters
#
# [*credentials_location*]
#   The location to store the credentials for nagios to access the nessus
#   reports.
<<<<<<< HEAD
#   Not required. Defaults to /etc/nagios/conf.d/puppet/credentials_nessus
=======
#   Not required. Defaults to /etc/nagios3/conf.d/puppet/credentials_nessus
>>>>>>> 1e86654231d7c29360426c7db6fb721c0f31061c
#
# [*username*]
#   The username to connect to nessus with
#   Not required. Defaults to root
#
# [*password*]
#   The password to use to connect to nessus/
#   Required.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com>
class nagios::server::plugins::nessus_reports (
<<<<<<< HEAD
  $credentials_location = '/etc/nagios/conf.d/puppet/credentials_nessus',
=======
  $credentials_location = '/etc/nagios3/conf.d/puppet/credentials_nessus',
>>>>>>> 1e86654231d7c29360426c7db6fb721c0f31061c
  $username             = 'root',
  $password) {
  require nagios::server::config
  include nagios::server::service
  
  package { 'jq' :
    ensure => installed
  }

  file { 'check_nessus_reports.sh':
    ensure => present,
    path   => '/usr/lib/nagios/plugins/check_nessus_reports.sh',
    source => 'puppet:///modules/nagios/server/plugins/check_nessus_reports.sh',
    owner  => 'nagios',
    group  => 'nagios',
    mode   => '0755',
  }

  nagios_command { 'check_nessus_reports':
    ensure       => 'present',
    command_name => 'check_nessus_reports',
    command_line => '/usr/lib/nagios/plugins/check_nessus_reports.sh -s $ARG1$ -C $ARG2$ -t $ARG3$ -w $ARG4$ -c $ARG5$',
<<<<<<< HEAD
    target       => '/etc/nagios/conf.d/puppet/command_nagios.cfg',
=======
    target       => '/etc/nagios3/conf.d/puppet/command_nagios.cfg',
>>>>>>> 1e86654231d7c29360426c7db6fb721c0f31061c
    notify       => Exec['rechmod'],
  }

  if $credentials_location != '' {
    file { $credentials_location:
      ensure    => present,
      content   => template('nagios/server/plugins/credentials'),
      mode      => '0600',
      owner     => 'nagios',
      group     => 'nagios',
      show_diff => false
    }

  }

}