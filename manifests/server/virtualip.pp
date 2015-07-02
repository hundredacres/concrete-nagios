class nagios::server::virtualip (
  $monitoring_environment = $::nagios::server::config::monitoring_environment) {
  require nagios::server::config
  include nagios::server::service

  Datacat_fragment <<| tag == "virtualip_${monitoring_environment}" |>> {
  }

  datacat { '/etc/nagios3/conf.d/puppet/host_virtualips.cfg': template => 'nagios/virtualip.cfg.erb', 
  }

}
