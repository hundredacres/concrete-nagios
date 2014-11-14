define nagios::nrpe::http ($health_check_uri = "/", $port = "80", $has_parent = false, $parent_service = "/", $ssl = false,) {
  require nagios::nrpe::config
  include nagios::nrpe::service
  include nagios::params
  $nagios_service = $::nagios::params::nagios_service

  if $ssl == true {
    $protocol = "HTTPS"
    $command = "check_https_nonroot_custom_port"
  } else {
    $protocol = "HTTP"
    $command = "check_http_nonroot_custom_port"
  }

  # This will use the name as the hostname to check ( this is really important with ssl! Can add a parameter if we thing of a
  # usecase

  @@nagios_service { "check_${name}_${protocol}_on_${hostname}":
    check_command       => "${command}!${name}!${health_check_uri}!${port}",
    use                 => "${nagios_service}",
    host_name           => $hostname,
    target              => "/etc/nagios3/conf.d/puppet/service_${fqdn}.cfg",
    service_description => "${hostname}_check_${name}_${protocol}",
    tag                 => "${environment}",
  }

  if $has_parent == true {
    @@nagios_servicedependency { "${name}_on_${hostname}_depencency_process":
      dependent_host_name           => $hostname,
      dependent_service_description => "${hostname}_check_${name}_${protocol}",
      host_name => $hostname,
      service_description           => "${parent_service}",
      execution_failure_criteria    => "c",
      notification_failure_criteria => "c",
      target    => "/etc/nagios3/conf.d/puppet/service_dependencies_${fqdn}.cfg",
      tag       => "${environment}",
    }
  }

  if $has_parent == true {
    @motd::register { "Nagios ${protocol} Check for ${name} and service dependency on ${parent_service}": }
  } else {
    @motd::register { "Nagios ${protocol} Check for ${name}": }
  }
}