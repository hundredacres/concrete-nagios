class nagios::server::config {
  require nagios::server::package
  include nagios::server::service

  file_line { "check_external_commands":
    line   => "check_external_commands=1",
    path   => "/etc/nagios3/nagios.cfg",
    match  => "check_external_commands",
    ensure => present,
    notify => Service[nagios3],
  }

  file { "/etc/nagios3/conf.d/puppet/":
    ensure  => directory,
    #                purge => true,
    recurse => true,
    force   => true,
    owner   => root,
    group   => nagios,
    mode    => "0640",
  }

  define nagios_collector () {
    Nagios_host <<| tag == "${environment}" |>> {
    }

    Nagios_service <<| tag == "${environment}" |>> {
    }

    Nagios_command <<| tag == "${environment}" |>> {
    }
    
    Nagios_servicegroup <<| tag == "${environment}" |>> {
    }

  }

  nagios_collector { "collect_it":
    require => File["/etc/nagios3/conf.d/puppet/"],
    notify  => Exec["rechmod"],
  }

  @motd::register { 'Nagios Server and Check/Host Collection': }

}
