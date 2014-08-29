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
    before => File_line[check_iostat],
  }

  case $::processorcount {
    '1'     : {
      $check = "command[check_iostat]=/usr/lib/nagios/plugins/check_iostat.sh -d xvda -W -w 999,100,200,50,80 -c 999,200,300,100,100"
    }
    '2'     : {
      $check = "command[check_iostat]=/usr/lib/nagios/plugins/check_iostat.sh -d xvda -W -w 999,100,200,50,40 -c 999,200,300,100,50"
    }
    '3'     : {
      $check = "command[check_iostat]=/usr/lib/nagios/plugins/check_iostat.sh -d xvda -W -w 999,100,200,50,27 -c 999,200,300,100,33"
    }
    '4'     : {
      $check = "command[check_iostat]=/usr/lib/nagios/plugins/check_iostat.sh -d xvda -W -w 999,100,200,50,20 -c 999,200,300,100,25"
    }
    '5'     : {
      $check = "command[check_iostat]=/usr/lib/nagios/plugins/check_iostat.sh -d xvda -W -w 999,100,200,50,16 -c 999,200,300,100,20"
    }
    '6'     : {
      $check = "command[check_iostat]=/usr/lib/nagios/plugins/check_iostat.sh -d xvda -W -w 999,100,200,50,14 -c 999,200,300,100,16"
    }
    '7'     : {
      $check = "command[check_iostat]=/usr/lib/nagios/plugins/check_iostat.sh -d xvda -W -w 999,100,200,50,12 -c 999,200,300,100,14"
    }
    default : {
      $check = "command[check_iostat]=/usr/lib/nagios/plugins/check_iostat.sh -d xvda -W -w 999,100,200,50,10-c 999,200,300,100,12.5"
    }
  }

  file_line { "check_iostat":
    line   => $check,
    path   => "/etc/nagios/nrpe_local.cfg",
    match  => "command\[check_iostat\]",
    ensure => present,
    notify => Service[nrpe],
  }

  case $::environment {
    'testing'     : { $service = "generic-service" }
    'development' : { $service = "generic-service-excluding-pagerduty" }
    default       : { $service = "generic-service-excluding-pagerduty" }
  }

  @@nagios_service { "check_iostat_${hostname}":
    check_command       => "check_nrpe_1arg_longtimeout!check_iostat",
    use                 => $service,
    host_name           => $hostname,
    target              => "/etc/nagios3/conf.d/puppet/service_${fqdn}.cfg",
    service_description => "${hostname}_check_iostat",
    tag                 => "${environment}",
  }

}
