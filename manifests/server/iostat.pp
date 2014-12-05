# == Class: nagios::server::iostat
#
# This is going to collect and collate the service groups from the iostat checks. This could be changed if there were
# other checks that required a similar process.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com
class nagios::server::iostat {
  require nagios::server::config
  include nagios::server::service

  Datacat_fragment <<| tag == "iostat_${::environment}" |>> {
  }

  datacat { '/etc/nagios3/conf.d/puppet/servicegroups_iostat.cfg': template => 'nagios/servicegroup_iostat.cfg.erb', }

}