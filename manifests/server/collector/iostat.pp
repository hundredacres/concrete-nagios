# == Class: nagios::server::collector::iostat
#
# This is going to collect and collate the service groups from the iostat
# checks. This could be changed if there were other checks that required a
# similar process.
#
# === Parameters
#
# [*monitoring_environment*]
#   This is the environment that the check will be submitted for. This will
#   default to the value set by nagios::server::config but can be overridden here.
#   Not required. 
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com>
class nagios::server::collector::iostat (
  $monitoring_environment = $::nagios::server::config::monitoring_environment) {
  require nagios::server::config
  include nagios::server::service

  Datacat_fragment <<| tag == "iostat_${monitoring_environment}" |>> {
  }

<<<<<<< HEAD
  datacat { '/etc/nagios/conf.d/puppet/servicegroups_iostat.cfg':
    template => 'nagios/server/collector/servicegroup_iostat.cfg.erb',
    notify   => Service['nagios']
=======
  datacat { '/etc/nagios3/conf.d/puppet/servicegroups_iostat.cfg':
    template => 'nagios/server/collector/servicegroup_iostat.cfg.erb',
    notify   => Service['nagios3']
>>>>>>> 1e86654231d7c29360426c7db6fb721c0f31061c
  }

}
