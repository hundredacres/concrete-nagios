# == Class: nagios::virtualip
#
# This will create a virtualip for a cluster. This can be submitted multiple
# times as nagios::server::virtualip will remove any extra so it is configured
# once.
#
# === Parameters
#
# [*virtualip*]
#   The ip address for the virtualip.
#   Required.
#
# [*cluster_name*]
#   The name of the cluster, which will be used as the name of the client.
#   Required.
#
# [*parent*]
#   The name of the parents for the virtualip, will probably be the hostname of
#   the cluster server. These will be merged together, so you only need each
#   server to submit its own hostname.
#   Required.
#
# [*monitoring_environment*]
#   This is the environment that the check will be submitted for. This will
#   default to the value set by nagios::server::config but can be overridden
#   here.
#   Required.
#
# === Examples
#
#  class { '::nagios::virtualip':
#    parent                 => $::hostname,
#    cluster_name           => $cluster_name,
#    virtualip              => $virtualip,
#    monitoring_environment => 'development'
#  }
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com>
class nagios::virtualip (
  $virtualip,
  $cluster_name,
  $parent,
  $monitoring_environment) {
  @@datacat_fragment { "${::hostname} Virtual ip":
<<<<<<< HEAD
    target => '/etc/nagios/conf.d/puppet/host_virtualips.cfg',
=======
    target => '/etc/nagios3/conf.d/puppet/host_virtualips.cfg',
>>>>>>> 1e86654231d7c29360426c7db6fb721c0f31061c
    data   => {
      $cluster_name => {
        virtualip => [$virtualip],
        parent    => [$parent],
      }
    }
    ,
    tag    => "virtualip_${monitoring_environment}",
  }
}