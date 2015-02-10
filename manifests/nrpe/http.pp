# == Define: nagios::nrpe::http
#
# This class will allow us to check the http response from a server. This will
# currently respond with OK for a 200/300 response, Warning for a 400 response,
# and Critical for no response. This  may want to be tuned. There is also an
# option in the check (but not this manifest) to allow greater response parsing.
# This can be integrated later as situations require.
#
# Note: This require the server having nagios::server::clean or the commands
# manually defined.
#
# === Parameters
#
# [*namevar*]
#   The hostname will default to the name of the resource. This is the hostname
#   that the check will send the request to. This will bypass dns, but will make
#   impacts on web servers with more than one hostname and also servers serving
#   https (complete necessity here).
#
# [*health_check_url*]
#   The sub url to check i.e. /ping or /health_check.
#   Not required. Defaults to /
#
# [*port*]
#   The port to check. Annoyingly, will require an override if you use https
#   (set it to 443), as the default is 80.
#   Not required. Defaults to 80
#
# [*has_parent*]
#   Whether this http response has a parent service dependency (eg nginx,
#   tomcat).
#   Not required. Defaults to true.
#
# [*parent_service*]
#   The name of the parent service, if has_parent is set to true (eg
#   ${hostname}_check_nginx).
#   Required if has parent is true. Defaults to "".
#
#   Note: This is not tested.
#
# [*ssl*]
#   Boolean for whether it should use http or https. Note: You will have to
#   change the port as well!
#   Not required. Defaults to false
#
# === Variables
#
# [*nagios_service*]
#   This is the generic service it will implement. This is set from
#   nagios::params. This should be set by heira in the future.
#
# [*command*]
#   This is the command that nrpe will use to check the file count.
#
# [*protocol*]
#   The represents the string for the connection protocol. Translation of ssl.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com
define nagios::nrpe::http (
  $host             = $name,
  $health_check_uri = '/',
  $port             = '80',
  $has_parent       = false,
  $parent_service   = '',
  $ssl              = false,) {
  require nagios::nrpe::config
  include nagios::nrpe::service
  include nagios::params

  $nagios_service = $::nagios::params::nagios_service

  if $ssl == true {
    $protocol = 'HTTPS'
    $command = 'check_https_nonroot_custom_port'
  } else {
    $protocol = 'HTTP'
    $command = 'check_http_nonroot_custom_port'
  }

  # This will use the name as the hostname to check ( this is really important
  # with ssl! Can add a parameter if we thing
  # of a usecase

  @@nagios_service { "check_${host}_${protocol}_on_${::hostname}":
    check_command       => "${command}!${host}!${health_check_uri}!${port}",
    use                 => $nagios_service,
    host_name           => $::hostname,
    target              => "/etc/nagios3/conf.d/puppet/service_${::fqdn}.cfg",
    service_description => "${::hostname}_check_${host}_${protocol}",
    tag                 => $::environment,
  }

  if $has_parent == true {
    @@nagios_servicedependency { "${host}_on_${::hostname}_depencency_process":
      dependent_host_name           => $::hostname,
      use       => $nagios_service,
      dependent_service_description => "${::hostname}_check_${host}_${protocol}",
      host_name => $::hostname,
      service_description           => $parent_service,
      execution_failure_criteria    => 'c',
      notification_failure_criteria => 'c',
      target    => "/etc/nagios3/conf.d/puppet/service_dependencies_${::fqdn}.cfg",
      tag       => $::environment,
    }
  }

  if $has_parent == true {
    @motd::register { "Nagios ${protocol} Check for ${host} and service dependency on ${parent_service}"
    : }
  } else {
    @motd::register { "Nagios ${protocol} Check for ${host}": }
  }
}