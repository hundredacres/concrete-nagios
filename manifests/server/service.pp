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
    command     => '/bin/chown -R root:nagios /etc/nagios3/conf.d/puppet/ && /bin/chmod 640 /etc/nagios3/conf.d/puppet/*',
    refreshonly => true,
    notify      => Service['nagios3'],
  }

  service { 'nagios3':
    ensure  => running,
    enable  => true,
    require => Package['nagios3'],;
  }

}
