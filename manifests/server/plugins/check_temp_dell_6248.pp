# == Class: nagios::server::check_temp_dell_6248
#
# This is going to set up a plugin that will check the temperate on a dell 6248
# switch and create a nagios command that will check it is under certain bounds.
#
# === Parameters
#
# [*warning*]
#   The warning temperature for the switch
#   Not required. Defaults to 30
#
# [*critical*]
#   The critical temperature for the switch
#   Not required. Defaults to 30
#
# === Authors
#
# Ben Field <ben.field@concreteplatform.com>
class nagios::server::plugins::check_temp_dell_6248 (
  $warning  = '30',
  $critical = '35') {
  require nagios::server::config
  include nagios::server::service

  ensure_packages('snmp', {
    'ensure' => 'installed'
  }
  )

  file { 'check_temp_dell_6248.sh':
    ensure => present,
    path   => '/usr/lib/nagios/plugins/check_temp_dell_6248.sh',
    source => 'puppet:///modules/nagios/server/plugins/check_temp_dell_6248.sh',
    owner  => 'nagios',
    group  => 'nagios',
    mode   => '0755',
  }

  nagios_command { 'check_temp_dell_6248':
    ensure       => 'present',
    command_name => 'check_temp_dell_6248',
    command_line => "/usr/lib/nagios/plugins/check_temp_dell_6248.sh -C \$ARG1\$ -i \$HOSTADDRESS\$ -w ${warning} -c ${critical}",
    target       => '/etc/nagios/conf.d/puppet/command_nagios.cfg',
    notify       => Exec['rechmod'],
  }
}