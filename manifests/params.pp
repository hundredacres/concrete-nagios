#Replace this with heira when I've got a better grip on how it works.

class ntp::params {
  
    case $::environment {
    'testing'     : { $server = "192.168.90.223" }
    'development' : { $server = "192.168.90.99" }
    default       : { $server = "192.168.90.223" }
  }
}