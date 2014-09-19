class nagios::server::iostat {
  require nagios::server::config
  include nagios::server::service

  Datacat_fragment <<| tag == "iostat_${environment}" |>> {
  }

  datacat { '/etc/nagios3/conf.d/puppet/servicegroups_iostat.cfg': template => "nagios/servicegroup_iostat.cfg.erb", }

}