# Class: jbossas
#
# This module manages JBoss Application Server 7.x
#
# Parameters:
# * @version@      = '7.1.1.Final'
# * @mirror_url@   = 'http://download.jboss.org/jbossas/7.1/jboss-as-7.1.1.Final/'
# * @bind_address@ = '127.0.0.1'
# * @http_port@    = 8080
# * @https_port@   = 8443
#
# Actions:
#
# Requires:
# * package curl
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class jbossas (
  $version = '7.1.1.Final',
  # Mirror URL with trailing slash
  # Will use curl to download, so 'file:///' is also possible not just 'http://'
  $mirror_url = 'http://download.jboss.org/jbossas/7.1/jboss-as-7.1.1.Final/',
  $bind_address = '127.0.0.1',
  $http_port = 8080,
  $https_port = 8443,
  $enable_service = true)
{
  $dir = '/usr/share/jboss-as'
  Class['install'] -> Class['initd']
  include install
  include initd

  # Configure
  notice "Bind address: $bind_address - HTTP Port: $http_port - HTTPS Port: $https_port"
  exec {
    'jbossas_http_port':
      command   => "/bin/sed -i -e 's/socket-binding name=\"http\" port=\"[0-9]\\+\"/socket-binding name=\"http\" port=\"${http_port}\"/' standalone/configuration/standalone.xml",
      user      => 'jbossas',
      cwd       => $dir,
      logoutput => true,
      require   => Class['jbossas::install'],
      unless    => "/bin/grep 'socket-binding name=\"http\" port=\"${http_port}\"/' standalone/configuration/standalone.xml",
      notify    => Service['jboss-as'];

    'jbossas_https_port':
      command   => "/bin/sed -i -e 's/socket-binding name=\"https\" port=\"[0-9]\\+\"/socket-binding name=\"https\" port=\"${https_port}\"/' standalone/configuration/standalone.xml",
      user      => 'jbossas',
      cwd       => $dir,
      logoutput => true,
      require   => Class['jbossas::install'],
      unless    => "/bin/grep 'socket-binding name=\"https\" port=\"${https_port}\"/' standalone/configuration/standalone.xml",
      notify    => Service['jboss-as'];
  }

  $ensure_service = $enable_service ? { true => running, default => undef }
  service {
    'jboss-as':
      ensure  => $ensure_service,
      enable  => $enable_service,
      require => [ Class['jbossas::initd'], Exec['jbossas_http_port'], Exec['jbossas_https_port'] ]
  }
}
