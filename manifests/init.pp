# puppetserver_gem_repo
#
# @summary Syncronize puppetserver gems from the master of masters to compile masters.
#
# @example
#   puppetserver_gem_repo { 'repo':
#     gem                 => 'hiera-eyaml',
#     version             => '2.1.0',
#     install_into_puppet => true,
#   }
#
# @param gem The name of the first gem to install.
# @param version The version of the gem to install.
# @param install_into_puppet Whether to install the gem into puppet in addition to the puppetserver service.

class puppetserver_gem_repo (

  Optional[String] $gem                 = undef,
  Optional[String] $version             = undef,
  Boolean          $install_into_puppet = false,

) {

  include puppetserver_gem_repo::conf

  if $puppetserver_gem_repo::conf::is_master_of_masters {
    include puppetserver_gem_repo::mom
  } else {
    include puppetserver_gem_repo::cm
  }

  if $gem {
    puppetserver_gem_repo::gem { $gem :
      version             => $version,
      install_into_puppet => $install_into_puppet,
    }
  }

}