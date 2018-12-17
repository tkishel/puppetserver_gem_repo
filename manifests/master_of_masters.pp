# Create a puppetserver jruby gem repository and archive on the master of masters.
#
# @api private

class puppetserver_gem_repo::master_of_masters (

  $private_class = 'do not directly apply this class',

) {

  $install_builder_gem = $puppetserver_gem_repo::conf::install_builder_gem
  $puppet_gem_command  = $puppetserver_gem_repo::conf::puppet_gem_command
  $jruby_gems_cache    = $puppetserver_gem_repo::conf::jruby_gems_cache
  $repository          = $puppetserver_gem_repo::conf::repository
  $repository_archive  = $puppetserver_gem_repo::conf::repository_archive

  # Optional, as some masters cannot access the internet.

  if $install_builder_gem {
    package { 'puppet_gem builder' :
      ensure   => present,
      name     => 'builder',
      provider => 'puppet_gem',
    }
  }

  # Create the puppetserver jruby gem cache directory structure.

  file { "${jruby_gems_cache}/.." :
    ensure => directory,
  }

  file { $jruby_gems_cache :
    ensure => directory,
  }

  # Create the puppetserver jruby gem repository directory structure.

  file { $repository :
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { "${repository}/ruby" :
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  # Copy gems from the cache to the repository.

  file { "${repository}/ruby/gems" :
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => $jruby_gems_cache,
    recurse => true,
    purge   => true,
    notify  => [ Exec['puppetserver_gem_repo generate_index'], Exec['puppetserver_gem_repo archive'] ],
  }

  # Generate the gem repository index.
  # Replaced creates => "${repository}/ruby/quick", with refreshonly.

  exec { 'puppetserver_gem_repo generate_index' :
    command     => "${puppet_gem_command} generate_index -d ${repository}/ruby",
    require     => [ Package['puppet_gem builder'], File["${repository}/ruby/gems"] ],
    refreshonly => true,
  }

  # Archive the repository to be synced to the other masters.

  exec { 'puppetserver_gem_repo archive' :
    command     => "tar --directory=${repository} -czf ${repository_archive} ruby",
    path        => '/usr/bin:/usr/sbin:/bin',
    require     => File["${repository}/ruby/gems"],
    refreshonly => true,
  }

}
