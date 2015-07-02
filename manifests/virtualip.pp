class nagios::virtualip (
  $virtualip,
  $cluster_name,
  $parent,
  $monitoring_environment) {
  @@datacat_fragment { "${cluster_name} Virtual ip":
    target => '/etc/nagios3/conf.d/puppet/host_virtualips.cfg',
    data   => {
      $cluster_name => {
        virtualip              => $virtualip,
        parent                 => $parent,
      }
    }
    ,
    tag    => "virtualip_${monitoring_environment}",
  }
}