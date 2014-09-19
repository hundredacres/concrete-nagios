class nagios::test {
  
  datacat_fragment { "$fqdn1 iostat in servicegroup":
    target => "/tmp/test.cfg",
    data   => ["xen01-off"],
  }
  
  datacat_fragment { "$fqdn2 iostat in servicegroup":
    target => "/tmp/test.cfg",
    data   => ["xen02-off"],
  }
  
    datacat { '/tmp/test.cfg': template => "nagios/servicegroup_iostat.conf.erb", }
}