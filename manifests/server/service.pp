# == Class: nagios::server::service
#
# This is going to check that all files have the correct permissions (this is
# due to puppet not really working quite right). Will also ensure the nagios
# server instance is running.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com>
class nagios::server::service {
  exec { 'rechmod':
<<<<<<< HEAD
    command     => '/bin/chown -R root:nagios /etc/nagios/conf.d/puppet/ && /bin/chmod 640 /etc/nagios/conf.d/puppet/*',
    refreshonly => true,
    notify      => Service['nagios'],
  }

  service { 'nagios':
    ensure  => running,
    enable  => true,
    require => Package['nagios'],
    restart => '/usr/sbin/nagios -v /etc/nagios/nagios.cfg && /etc/init.d/nagios reload'
=======
    command     => '/bin/chown -R root:nagios /etc/nagios3/conf.d/puppet/ && /bin/chmod 640 /etc/nagios3/conf.d/puppet/*',
    refreshonly => true,
    notify      => Service['nagios3'],
  }

  service { 'nagios3':
    ensure  => running,
    enable  => true,
    require => Package['nagios3'],
    restart => '/usr/sbin/nagios3 -v /etc/nagios3/nagios.cfg && /etc/init.d/nagios3 reload'
>>>>>>> 1e86654231d7c29360426c7db6fb721c0f31061c
  }

}
