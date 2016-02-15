# == Class: nagios::server::collector::virtualip
#
# This is going to collect and collate the virtualips submitted by
# nagios::virtualip into a virtualip file that nagios can read.
#
# === Parameters
#
# [*monitoring_environment*]
#   This is the environment that the check will be submitted for. This will
#   default to the value set by nagios::server::config but can be overridden
#   here.
#   Not required.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com>
class nagios::server::collector::virtualip (
  $monitoring_environment = $::nagios::server::config::monitoring_environment) {
  require nagios::server::config
  include nagios::server::service

  Datacat_fragment <<| tag == "virtualip_${monitoring_environment}" |>> {
  }

<<<<<<< HEAD
  datacat { '/etc/nagios/conf.d/puppet/host_virtualips.cfg':
    template => 'nagios/server/collector/virtualip.cfg.erb',
    notify   => Service['nagios']
=======
  datacat { '/etc/nagios3/conf.d/puppet/host_virtualips.cfg':
    template => 'nagios/server/collector/virtualip.cfg.erb',
    notify   => Service['nagios3']
>>>>>>> 1e86654231d7c29360426c7db6fb721c0f31061c
  }

}
