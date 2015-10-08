class nagios::server::plugins::check_temp_dell_6248 {
  require nagios::server::config
  include nagios::server::service

  package { 'snmp': ensure => installed, }

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
    command_line => '/usr/lib/nagios/plugins/check_temp_dell_6248.sh -C $ARG1$ -i $HOSTADDRESS$ -w 30 -c 35',
    target       => '/etc/nagios3/conf.d/puppet/command_nagios.cfg',
    notify       => Exec['rechmod'],
  }
}