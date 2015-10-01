# == Class: nagios::server::config
#
# This is going to configure the server and collect all the submitted services
# etc. This uses the dodgy define nagios::nrpe::collector. There is no way to
# achieve this otherwise - the owner/group will always be root!
#
# === Parameters
#
# [*monitoring_environment*]
#   This is the environment that the recieve checks and clients from. . This
#   will override the value for the define that it implements.
#   Required
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com
class nagios::server::config (
  $monitoring_environment,
  $password,
  $salt = generate_password(12, 'nagios')) {
  require nagios::server::package
  include nagios::server::service

  file_line { 'check_external_commands':
    ensure => present,
    line   => 'check_external_commands=1',
    path   => '/etc/nagios3/nagios.cfg',
    match  => 'check_external_commands',
    notify => Service['nagios3'],
  }

  file { '/etc/nagios3/conf.d/puppet/':
    ensure  => directory,
    # purge => true,
    recurse => true,
    force   => true,
    owner   => 'root',
    group   => 'nagios',
    mode    => '0640',
  }

  nagios::server::collector { 'collect_it':
    monitoring_environment => $monitoring_environment,
    require                => File['/etc/nagios3/conf.d/puppet/'],
    notify                 => Exec['rechmod'],
  }

  $encrypted_password = ht_crypt($password, $salt)

  htpasswd { 'nagiosadmin':
    cryptpasswd => $encrypted_password,
    target      => '/etc/nagios3/htpasswd.users',
  }

}
