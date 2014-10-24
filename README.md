UIMA
====

 This module manages installation of UIMA and UIMA-AS from source, as well as installing the UIMA eclipse plugins

Parameters:
----------- 
 * version
   - The version of UIMA, UIMA-AS and eclipse plugins (other than ruta, which does not have versions all the way to the latest number)   
 * ruta_version
   - The version of the ruta eclipse plugin 
 * revision
   - If pulling the latest UIMA and UIMA-AS from trunk, the revision to pull.  If left undefined, pulls latest revision
 * eclipsenv
   - Eclipse release to install.  If set to undef, skips installation of eclipse
 * eclipserel
   - Service release of eclipse to install 
 * install_prereqs
   - Whether to install prerequisites for UIMA and UIMA-AS and set the JAVA_HOME environment variable