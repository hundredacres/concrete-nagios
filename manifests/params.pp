# Replace this with heira when I've got a better grip on how it works.

class nagios::params {
  case $::environment {
    'production'  : { $server = "192.168.100.5" }
    'testing'     : { $server = "192.168.90.223" }
    'development' : { $server = "192.168.90.99" }
    default       : { $server = "192.168.90.223" }
  }
  
#  if $::service_class != "" {
#    $service_class
#  }
}