# == Class: nagios::server::config
#
# This is going to configure the server and collect all the submitted services etc. This has a really awkward define, as
# this is the only way to chmod the files afterwards. There is no way to achieve this otherwise - the owner/group will
# always be root!
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com
class nagios::server::config {
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

  define nagios_collector () {
    Nagios_host <<| tag == "${::environment}" |>> {
    }

    Nagios_service <<| tag == "${::environment}" |>> {
    }

    Nagios_command <<| tag == "${::environment}" |>> {
    }

    Nagios_servicegroup <<| tag == "${::environment}" |>> {
    }

    Nagios_servicedependency <<| tag == "${::environment}" |>> {
    }

  }

  nagios_collector { "collect_it":
    require => File["/etc/nagios3/conf.d/puppet/"],
    notify  => Exec["rechmod"],
  }

  @motd::register { 'Nagios Server and Check/Host Collection': }

}
