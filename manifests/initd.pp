class jbossas::initd {
  # init.d configuration for Ubuntu
  $jbossas_bind_address = $jbossas::bind_address

  file { '/etc/jboss-as':
    ensure => directory,
    owner  => 'root', group => 'root';
  }
  file { '/etc/jboss-as/jboss-as.conf':
    content => template('jbossas/jboss-as.conf.erb'),
    owner   => 'root', group => 'root',
    mode    => '0644',
    require => File['/etc/jboss-as'];
  }
  file { '/var/run/jboss-as':
    ensure => directory,
    owner  => 'jbossas', group => 'jbossas',
    mode   => '0775';
  }
  file { '/etc/init.d/jboss-as':
    source => 'puppet:///modules/jbossas/init.d/jboss-as-standalone.sh',
    owner  => 'root', group => 'root',
    mode   => '0755';
  }
}
