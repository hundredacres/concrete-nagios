class nagios::server::iostat {
  require nagios::server::config
  include nagios::server::service

  Datacat_fragment <<| tag == "iostat_${environment}" |>> {
  }

  datacat { '/etc/nagios3/conf.d/puppet/servicegroups_iostat.conf': template => "nagios/servicegroup_iostat.conf.erb", }

}