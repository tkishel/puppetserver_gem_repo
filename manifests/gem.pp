# puppetserver_gem_repo::gem
#
# @summary Install a puppetserver gem from the master of masters to compile masters.
#
# @example
#   puppetserver_gem_repo::gem { 'hiera-eyaml':
#     version             => '2.1.0',
#     install_into_puppet => true,
#   }
#
# @api public
#
# @param version The version of the gem to install.
# @param install_into_puppet Whether to install the gem into puppet in addition to the puppetserver service.

define puppetserver_gem_repo::gem (

  String  $gem                 = $title,
  String  $version             = 'present',
  Boolean $install_into_puppet = false,

) {

  assert_type(Pattern[/^[\w\-]+$/], $gem) |$expected, $actual| {
    fail("Module ${module_name} parameter 'gem => ${gem}' is not a valid gem name")
  }

  assert_type(Variant[Pattern[/^present$/],Pattern[/^\d+\.\d+\.\d+$/]], $version) |$expected, $actual| {
    fail("Module ${module_name} parameter 'version => ${version}' is not a valid gem version")
  }

  include puppetserver_gem_repo::conf

  $puppetserver_gem_command  = $puppetserver_gem_repo::conf::puppetserver_gem_command
  $puppetserver_gems         = $puppetserver_gem_repo::conf::jruby_gems
  $repository                = $puppetserver_gem_repo::conf::repository
  $gem_source                = "file://${repository}/ruby"
  $gem_install_options       = "--no-ri --no-rdoc --clear-sources --source ${gem_source}"
  $gem_install_options_array = ['--no-ri', '--no-rdoc', '--clear-sources', '--source', $gem_source]

  # Install the gem into puppetserver ...

  # The puppetserver_gem requires an additional module, and jruby is incredibly slow.
  if ! $puppetserver_gem_repo::conf::is_master_of_masters {
    $version_gi = $version ? {'present' => '', default => "-v ${version}"}
    $version_ls = $version ? {'present' => '*', default => $version}
    $service = $::pe_server_version ? { undef => 'puppetserver', default => 'pe-puppetserver'}
    exec { "puppetserver install gem ${gem}" :
      command => "${puppetserver_gem_command} install ${gem} ${version_gi} ${gem_install_options}",
      unless  => "ls ${puppetserver_gems}/${gem}-${version_ls} 1>/dev/null 2>&1",
      path    => '/usr/bin:/usr/sbin:/bin',
      require => File[$repository],
      notify  => Service[$service],
    }
  }

  # Install the gem into puppet ...

  if $install_into_puppet {
    package { "puppet_gem ${gem}" :
      ensure          => $version,
      name            => $gem,
      provider        => 'puppet_gem',
      install_options => $gem_install_options_array,
      require         => File[$repository],
    }
  }

}
