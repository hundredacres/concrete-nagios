# == Define: nagios::nrpe::blockdevice::diskspace
#
# This will take a drive reference as the name, and use it to create a diskspeed check. The warning level for io load
# will be 80% of one core and 100% of one core for critical
#
# Note: It will set the name of the check to reference sysvol not xvda for cleanness in the nagios server
#
# === Parameters
#
# [*namevar*]
#   This will provide the drive reference (ie xvda from xen machines). Note: this will ignore
#   xvdd and sr0 as these are names for cd drives by default and could cause errors
#
# === Variables
#
# [*nagios_service*]
#   This is the generic service it will implement. This is set from nagios::params.
#   This should be set by heira in the future.
#
# === Examples
#
#   nagios::nrpe::blockdevice::diskspace { 'xvda':
#   }
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com
define nagios::nrpe::blockdevice::iostat {
  if $name != "xvdd" and $name != "sr0" {
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
    }

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

    @motd::register { "Nagios Diskspeed Check $name": }
  }
}