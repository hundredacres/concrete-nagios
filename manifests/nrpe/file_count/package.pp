class nagios::nrpe::file_count::package {
  file { "check_file_count.sh":
    path   => "/usr/lib/nagios/plugins/check_file_count.sh",
    source => "puppet:///modules/nagios/check_file_count.sh",
    owner  => nagios,
    group  => nagios,
    mode   => "0755",
    ensure => present,
  }
}