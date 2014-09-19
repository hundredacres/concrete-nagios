#Factored out to avoid issues where it was called in two places

class nagios::eventhandlers{
  
    file { "/usr/lib/nagios/eventhandlers":
    ensure  => directory,
    recurse => true,
    owner   => root,
    group   => root,
    mode    => 755,
  }
  
}