# Publish a gem repository on the master of masters.

class puppetserver_gem_repo::mom (

  $private_api = 'do not directly apply this class',

) {

  $gem_command        = $puppetserver_gem_repo::conf::puppet_gem_command
  $gem_cache          = $puppetserver_gem_repo::conf::jruby_gem_cache
  $repository         = $puppetserver_gem_repo::conf::repository
  $repository_archive = $puppetserver_gem_repo::conf::repository_archive

  package { 'puppet_gem builder' :
    ensure   => present,
    name     => 'builder',
    provider => 'puppet_gem',
  }

  file { $repository :
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { "${repository}/ruby" :
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package['puppet_gem builder'],
  }

  file { "${repository}/ruby/gems" :
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => $gem_cache,
    recurse => true,
    purge   => true,
    notify  => [ Exec['puppetserver_gem_repo generate_index'], Exec['puppetserver_gem_repo archive'] ]
  }

  exec { 'puppetserver_gem_repo generate_index' :
    command => "${gem_command} generate_index -d ${repository}/ruby",
    creates => "${repository}/ruby/quick",
    require => File["${repository}/ruby/gems"],
  }

  exec { 'puppetserver_gem_repo archive' :
    command => "tar --directory=${repository} -czf ${repository_archive} ruby",
    path    => '/usr/bin:/usr/sbin:/bin',
    creates => $repository_archive,
    require => File["${repository}/ruby/gems"],
  }

}
