class uima::params {
  
  $uima_eclipse_ps = 'http://www.apache.org/dist/uima/eclipse-update-site/'
  
  $uimahome = "/usr/src/uimaj/target/apache-uima"
  $uimasrc = "/usr/src/uimaj"
  $uimaassrc = "/usr/src/uima-as"
  
  case $::osfamily {

    'Debian': {
      
		  $prereqs = [
		    'maven',
		    'openjdk-7-jdk',
		  ]

      $javahome = "/usr/lib/jvm/java-7-openjdk-amd64"
    }

    default: {
        fail("Unsupported osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}, module ${module_name} only support osfamily Debian")
    }
    
  }
  
  $exec_mvn_defaults = {
    environment => [
      "JAVA_HOME=${javahome}",
      "UIMA_HOME=${uimahome}",
    ], 
    path => [
      '/bin',
      '/usr/bin',
    ], 
    timeout => 0,
    refreshonly => true,
    tag => 'maven',
  }
}