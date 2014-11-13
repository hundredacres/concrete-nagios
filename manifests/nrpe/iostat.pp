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

  # @@nagios_servicegroup { "diskspeed":
  #   alias  => "Disk Speed",
  #   target => "servicegroup_$name",
  #   tag    => "${environment}",
  #}


  # This is a bit dirty. We could use nagios_servicegroups, but we want some way to be dynamic with our iostat service groups.
  # Easiest way is to throw it all
  # together into a single text file using datacat. Gonna add the xenhost name into the array.

  @@datacat_fragment { "$fqdn iostat in servicegroup":
    target => "/etc/nagios3/conf.d/puppet/servicegroups_iostat.cfg",
    data   => {
      host => ["${xenhost}"],
    }
    ,
    tag    => "iostat_${environment}",
  }

  $drive = split($::blockdevices, ",")

  nagios::nrpe::iostat::blockdevice_check { $drive: require => File["check_iostat.sh"] }

  # Create a definition that we can loop through
  # May need to review what we consider to be actionable levels for meaningful alerting on these... --Justin
  define nagios::nrpe::iostat::blockdevice_check {
    if $name != "xvdd" and $name != "sr0" {
      # Fully dynamic check:

      $ioloadwarning = floor(80 / $::processorcount)
      $ioloadcritical = floor(100 / $::processorcount)

      $check = "command[check_iostat_$name]=/usr/lib/nagios/plugins/check_iostat.sh -d $name -W -w 999,100,200,75,${ioloadwarning} -c 999,200,300,150,${ioloadcritical}"

      file_line { "check_iostat_$name":
        line   => $check,
        path   => "/etc/nagios/nrpe_local.cfg",
        match  => "command\[check_iostat_$name\]",
        ensure => present,
        notify => Service[nrpe],
      }

      case $::environment {
        'production'  : { $service = "generic-service-excluding-pagerduty" }
        'testing'     : { $service = "generic-service" }
        'development' : { $service = "generic-service-excluding-pagerduty" }
        default       : { $service = "generic-service-excluding-pagerduty" }
      }

      if $name == "xvda" {
        $drive = "sysvol"
      } else {
        $drive = $name
      }

      @@nagios_service { "check_${drive}_iostat_${hostname}":
        check_command       => "check_nrpe_1arg_longtimeout!check_iostat_$name",
        use                 => $service,
        host_name           => $hostname,
        target              => "/etc/nagios3/conf.d/puppet/service_${fqdn}.cfg",
        service_description => "${hostname}_check_${drive}_iostat",
        tag                 => "${environment}",
        servicegroups       => "servicegroup_iostat_${xenhost}",
      # notifications_enabled => 0,
      }

      @motd::register { "Nagios Diskspeed Check $name": }

      @@nagios_servicedependency { "load_${name}_on_${hostname}_depencency_iostat":
        dependent_host_name           => $hostname,
        dependent_service_description => "${hostname}_check_load",
        host_name => $hostname,
        service_description           => "${hostname}_check_${drive}_iostat",
        execution_failure_criteria    => "w,c",
        notification_failure_criteria => "w,c",
        target    => "/etc/nagios3/conf.d/puppet/service_dependencies_${fqdn}.cfg",
        tag       => "${environment}",
      }

    }
  }

}
