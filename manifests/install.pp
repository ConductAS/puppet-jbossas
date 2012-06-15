class jbossas::install {
  $mirror_url_version = "${jbossas::mirror_url}jboss-as-${jbossas::version}.tar.gz"
  $dist_dir = '/home/jbossas/tmp'
  $dist_file = "${dist_dir}/jboss-as-${jbossas::version}.tar.gz"

  notice "Download URL: $mirror_url_version"
  notice "JBoss AS directory: $jbossas::dir"

  # Create group, user, and home folder
  group { jbossas:
    ensure => present
  }
  user { jbossas:
    ensure => present,
    managehome => true,
    gid => 'jbossas',
    require => Group['jbossas'],
    comment => 'JBoss Application Server'
  }
  file { '/home/jbossas':
    ensure => present,
    owner => 'jbossas',
    group => 'jbossas',
    mode => 0775,
    require => [ Group['jbossas'], User['jbossas'] ]
  }

  # Download the JBoss AS distribution ~100MB file
  exec { download_jboss_as:
    command => "/usr/bin/curl -v --progress-bar -o '$dist_file' '$mirror_url_version'",
    creates => $dist_file,
    user => 'jbossas',
    logoutput => true,
    require => Package['curl']
  }

  # Extract the JBoss AS distribution
  file { $dist_dir:
    ensure => directory,
    owner => 'jbossas', group => 'jbossas',
    mode => 0775,
    require => [ Group['jbossas'], User['jbossas'] ]
  }
  exec { extract_jboss_as:
    command => "/bin/tar -xz -f '$dist_file'",
    creates => "/home/jbossas/jboss-as-${jbossas::version}",
    cwd => '/home/jbossas',
    user => 'jbossas', group => 'jbossas',
    logoutput => true,
    unless => "/usr/bin/test -d '$jbossas::dir'",
    require => [ Group['jbossas'], User['jbossas'], Exec['download_jboss_as'] ]
  }
  exec { move_jboss_home:
    command => "/bin/mv -v '/home/jbossas/jboss-as-${jbossas::version}' '${jbossas::dir}'",
    creates => $jbossas::dir,
    logoutput => true,
    require => Exec['extract_jboss_as']
  }
  file { "$jbossas::dir":
    ensure => directory,
    owner => 'jbossas', group => 'jbossas',
    require => [ Group['jbossas'], User['jbossas'], Exec['move_jboss_home'] ]
  }

}
