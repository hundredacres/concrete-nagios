# Replace this with heira when I've got a better grip on how it works.

class nagios::params {
  case $::environment {
    'production'  : { $server = "192.168.100.5" }
    'testing'     : { $server = "192.168.90.223" }
    'development' : { $server = "192.168.90.99" }
    default       : { $server = "192.168.90.223" }
  }
  
  if $::service_class != "" {
	   $nagios_service = $::service_class
  } else {
    case $::environment {}
    'production'  : { $nagios_service = "generic_service" }
    'testing'     : { $nagios_service = "generic_service" }
    'development' : { $nagios_service = "generic_service" }
    default       : { $nagios_service = "generic_service" }
  }
  
  
  }
}