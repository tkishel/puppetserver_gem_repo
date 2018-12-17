# puppetserver_gem_repo::gem
#
# @summary Install a puppetserver jruby gem from a local copy of the repository on the master of masters.
#
# @example
#   puppetserver_gem_repo::gem {
#     name               => 'world_airports',
#     version            => '1.1.3',
#     install_into_agent => true,
#   }
#
# @api public
#
# @param version The version of the gem to install.
# @param install_into_agent Whether to install the gem into the puppet agent in addition to the puppetserver service.

define puppetserver_gem_repo::gem (

  String  $version            = 'present',
  Boolean $install_into_agent = false,

) {

  include puppetserver_gem_repo

  assert_type(Pattern[/^[\w\-]+$/], $title) |$expected, $actual| {
    fail("Module ${module_name} '${title}' is not a valid gem name")
  }

  assert_type(Variant[Pattern[/^present$/],Pattern[/^\d+\.\d+\.\d+$/]], $version) |$expected, $actual| {
    fail("Module ${module_name} parameter 'version => ${version}' is not a valid gem version")
  }

  $puppetserver_gem_command     = $puppetserver_gem_repo::conf::puppetserver_gem_command
  $puppetserver_gem_directories = $puppetserver_gem_repo::conf::puppetserver_gem_directories
  $puppet_shared_gem_directory  = $puppetserver_gem_repo::conf::puppet_shared_gem_directory
  $repository                   = $puppetserver_gem_repo::conf::repository
  $gem_source                   = "file://${repository}/ruby"
  $gem_install_options_string   = "--no-ri --no-rdoc --clear-sources --source ${gem_source}"
  $gem_install_options_array    = ['--no-ri', '--no-rdoc', '--clear-sources', '--source', $gem_source]

  # Install the gem into puppetserver, unless this is the master of masters.

  unless $puppetserver_gem_repo::conf::is_master_of_masters {

    # Note: FM-7145
    # The puppetserver_gem provider is incredibly slow, even when listing gems.
    # Use an 'exec' with 'unless' until that is resolved.
    #
    # $ca_certificate = $puppetserver_gem_repo::conf::puppet_ca_certificate
    # SSL_CERT_FILE=${ca_certificate} /opt/puppetlabs/puppet/bin/gem install --no-ri --no-rdoc --clear-sources --source https://$(puppet config print server):8140/packages/puppetserver_gems/ruby ${title}

    $version_gi = $version ? {'present' => '', default => "-v ${version}"}
    $version_ls = $version ? {'present' => '*', default => $version}
    $service = $::pe_server_version ? { undef => 'puppetserver', default => 'pe-puppetserver'}

    exec { "puppetserver install gem ${title}" :
      command => "${puppetserver_gem_command} install ${title} ${version_gi} ${gem_install_options_string}",
      unless  => "ls ${puppetserver_gem_directories}/${title}-${version_ls} 1>/dev/null 2>&1",
      path    => '/usr/bin:/usr/sbin:/bin',
      require => File[$repository],
      notify  => Service[$service],
    }

  }

  # Optioanlly install the gem into puppet agent.

  if $install_into_agent {

    package { "puppet_gem ${title}" :
      ensure          => $version,
      name            => $title,
      provider        => 'puppet_gem',
      install_options => $gem_install_options_array,
      require         => File[$repository],
    }

  }

}
