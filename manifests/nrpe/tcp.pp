# == Define: nagios::nrpe::tcp
#
# This class will allow us to check the response on a given port.
# This is useful if we want to check that a program is listening correctly but
# it doesnt serve http (see nagios::nrpe::http).
#
# Note: This require the server having nagios::server::clean or the commands
# manually defined.
#
# === Parameters
#
# [*port*]
#   The port to check.
#   Required.
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
# [*parent_service*]
#   The name of the parent host, if has_parent is set to true (eg
#   ${hostname}).
#   Defaults to $::hostname. Not required.
#
# [*monitoring_environment*]
#   This is the environment that the check will be submitted for. This will
#   default to the value set by nagios::nrpe::config but can be overridden here.
#   Not required. 
#
# [*nagios_service*]
#   This is the generic service that this check will implement. This should
#   be set by nagios::nrpe::config but can be overridden here. Not required.
#
# [*nagios_alias*]
#   This is the hostname that the check will be submitted for. This should
#   almost always be the hostname, but could be overriden, for instance when
#   submitting a check for a virtual ip. Not required.
#
# === Variables
#
# [*service_description*]
#   A placeholder for the service description that makes it slightly neater to
#   read.
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com
define nagios::nrpe::tcp (
  $port,
  $has_parent             = false,
  $parent_service         = '',
  $parent_host            = $::hostname,
  $monitoring_environment = $::nagios::nrpe::config::monitoring_environment,
  $nagios_service         = $::nagios::nrpe::config::nagios_service,
  $nagios_alias           = $::hostname,) {
  require nagios::nrpe::config
  include nagios::nrpe::service

  $service_description = "${nagios_alias}_check_port_${port}"

  @@nagios_service { "check_port_${port}_on_${nagios_alias}":
    check_command       => "check_tcp!${port}",
    use                 => $nagios_service,
    host_name           => $nagios_alias,
    target              => "/etc/nagios3/conf.d/puppet/service_${nagios_alias}.cfg",
    service_description => "${nagios_alias}_check_port_${port}",
    tag                 => $monitoring_environment,
  }

  if $has_parent == true {
    @@nagios_servicedependency { "check_port_${port}_on_${nagios_alias}_depencency_${parent_service}"
    :
      dependent_host_name           => $nagios_alias,
      dependent_service_description => $service_description,
      host_name => $parent_host,
      service_description           => $parent_service,
      execution_failure_criteria    => 'c',
      notification_failure_criteria => 'c',
      target    => "/etc/nagios3/conf.d/puppet/service_dependencies_${nagios_alias}.cfg",
      tag       => $monitoring_environment,
    }
  }
}
