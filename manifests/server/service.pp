class nagios::server::service {
  exec { "rechmod":
    command     => "/bin/chown -R root:nagios /etc/nagios3/conf.d/puppet/ && /bin/chmod 640 /etc/nagios3/conf.d/puppet/*",
    refreshonly => true,
    notify      => Service["nagios3"],
  }

  service { nagios3:
    ensure  => running,
    enable  => true,
    require => Package[nagios3],;
  }

}
