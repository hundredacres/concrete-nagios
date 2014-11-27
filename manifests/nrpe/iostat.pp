class nagios::nrpe::iostat {
  require nagios::nrpe::config
  require basic_server::basic_software
  include nagios::nrpe::service

  file { "check_iostat.sh":
    path   => "/usr/lib/nagios/plugins/check_iostat.sh",
    source => "puppet:///modules/nagios/check_iostat.sh",
    owner  => root,
    group  => root,
    mode   => "0755",
    ensure => present,
  }

  # This is a bit dirty. We could use nagios_servicegroups, but we want some way to be dynamic with our iostat service
  # groups.
  # Easiest way is to throw it all together into a single text file using datacat. Gonna add the xenhost name into the
  # array.

  @@datacat_fragment { "$fqdn iostat in servicegroup":
    target => "/etc/nagios3/conf.d/puppet/servicegroups_iostat.cfg",
    data   => {
      host => ["${xenhost}"],
    }
    ,
    tag    => "iostat_${environment}",
  }

  $drive = split($::blockdevices, ",")

  nagios::nrpe::blockdevice::iostat { $drive: require => File["check_iostat.sh"] }

}
