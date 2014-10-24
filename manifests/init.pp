# Class: uima
#
# This module manages installation of UIMA and UIMA-AS from source, as well as installing the UIMA eclipse plugins
#
# Parameters: 
# [*version*]
#   - The version of UIMA, UIMA-AS and eclipse plugins (other than ruta, which does not have versions all the way to the latest number) 
# [*ruta_version*]
#   - The version of the ruta eclipse plugin 
# [*revision*]
#   - If pulling the latest UIMA and UIMA-AS from trunk, the revision to pull.  If left undefined, pulls latest revision
# [*eclipsenv*]
#   - Eclipse release to install.  If set to undef, skips installation of eclipse
# [*eclipserel*]
#   - Service release of eclipse to install 
# [*install_prereqs*]
#   - Whether to install prerequisites for UIMA and UIMA-AS and set the JAVA_HOME environment variable
#
# Requires: see Modulefile
#
# Sample Usage:
#
class uima (
  $version = '2.6.0',
  $revision = undef,
  $ruta_version = 'latest',
  $eclipsenv  = 'kepler',
  $eclipserel = 'SR2',
  $install_prereqs = true,
) inherits uima::params {
  if $version == 'latest' {
    $uima_ver = ""
  }
  else {
    $uima_ver = $version
  }
  if $ruta_version == 'latest' {
    $ruta_ver = ""
  }
  else {
    $ruta_ver = $ruta_version
  }

  if $eclipsenv != undef and !defined(Class['eclipse']) {
	  package { "eclipse":
	    ensure => absent,
	  }
	  
	  class { "eclipse" :
	    method => 'download',
	    release_name => $eclipsenv,
	    service_release => $eclipserel,  
	  }
  
	  file { 'eclipseapp':
	    path => '/usr/bin/eclipse',
	    ensure => link,
	    target => '/opt/eclipse/eclipse',
	  }
	  
	  Package['eclipse'] -> File['eclipseapp']
	  Archive <| |> -> Eclipse::Plugin <| |>
	  Class['eclipse'] -> File['eclipseapp']
  }
  
  $eplugins = {
	  'uima-rt' => {
	    method => 'p2_director',
	    iu => "org.apache.uima.runtime.feature.group/${uima_ver}",
    },
	  'uima-tools' => {
      method => 'p2_director',
      repository => $uima::params::uima_eclipse_ps,
	    iu => "org.apache.uima.tools.feature.group/${uima_ver}",
    },
	  'uima-as' => {
      method => 'p2_director',
      repository => $uima::params::uima_eclipse_ps,
	    iu => "org.apache.uima.as.deployeditor.feature.group/${uima_ver}",
    },
	  'uima-ruta' => {
      method => 'p2_director',
      repository => $uima::params::uima_eclipse_ps,
	    iu => "org.apache.uima.ruta.feature.feature.group${ruta_ver}",
    },
  }
  create_resources(eclipse::plugin, $eplugins)
  
  if $version == 'latest' {
    $repodirj = "trunk"
    $repodiras = "trunk"
  }
  else {
    $repodirj = "tags/uimaj-${version}/"
    $repodiras = "tags/uima-as-${version}/"
  }
  $repos = {
	  '/usr/src/uimaj' => {
	    ensure => present,
	    provider => 'svn',
	    source => "https://svn.apache.org/repos/asf/uima/uimaj/${repodirj}",
	    tag => ['uima', 'maven'], 
	  },
	  '/usr/src/uima-as' => {
      ensure => present,
      provider => 'svn',
      source => "https://svn.apache.org/repos/asf/uima/uimaj/${repodiras}",
      tag => ['uima', 'maven'],
	  },
  }
  create_resources(vcsrepo, $repos)
  
  if $revision != undef {
    Vcsrepo <| tag == 'uima' |> {
      revision => $revision,
    }
  }
  
  $exec_mvn = {
	  'mvn_uimaj' => {
	    command => 'mvn clean install -Dmaven.test.skip',
	    cwd => $uima::params::uimasrc,
	  },
	  'mvn_uima-as' => {
	    command => 'mvn clean install -Dmaven.test.skip',
	    cwd => $uima::params::uimaassrc,
    },
  }
  create_resources(exec, $exec_mvn, $uima::params::exec_mvn_defaults)
  
  if $version != 'latest' {
	  archive::extract { "uima-as-${version}-bin":
	    target => "$uima::params::uimaassrc/target/",
	    src_target => "$uima::params::uimaassrc/target/",
	    tag => 'maven',
    }
	  archive::extract { "uimaj-${version}-bin":
      target => "$uima::params::uimasrc/target/",
      src_target => "$uima::params::uimasrc/target/",
      tag => 'maven',
    }
  
	  systemenv::var { 'uimahome':
	    varname => 'UIMA_HOME',
	    value => $uima::params::uimahome,
	  }
	  
	  Exec['mvn_uimaj'] ~> Archive::Extract["uimaj-${version}-bin"]
	  Exec['mvn_uima-as'] ~> Archive::Extract["uima-as-${version}-bin"]
  }
  
  if $install_prereqs {
    package { $uima::params::prereqs:
      ensure => installed,
      tag => 'uima-prereq',
    }

    systemenv::var { 'javahome':
	    varname => 'JAVA_HOME',
	    value => $uima::params::javahome,
	  }
	  
	  Package <| tag == 'uima-prereq' |> -> Vcsrepo <| tag == "maven" |> 
  }
  
  Vcsrepo <| tag == "maven" |> -> Exec <| tag == "maven" |>
  
  Vcsrepo['/usr/src/uimaj'] ~> Exec['mvn_uimaj']
  Vcsrepo['/usr/src/uima-as'] ~> Exec['mvn_uima-as']
  Exec["mvn_uimaj"] -> Exec["mvn_uima-as"]
}
