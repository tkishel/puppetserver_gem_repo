# @summary Install a list of puppetserver jruby gems from a local repository.
#
# @example
#
# include puppetserver_gem_repo::gems
#
# ---
# puppetserver_gem_repo::gems:
#   world_airports:
#     version:             1.1.3
#     install_into_agent:  true

class puppetserver_gem_repo::gems (
  Hash $gems  = {},
) {

  include puppetserver_gem_repo

  if ( (versioncmp($::clientversion, '4.9.0') >= 0) and (! defined('$::serverversion') or versioncmp($::serverversion, '4.9.0') >= 0) ) {
    $hiera_gems  = lookup('puppetserver_gem_repo::gems', Hash, 'hash', {})
  } else {
    $hiera_gems  = hiera_hash('puppetserver_gem_repo::gems', {})
  }

  $_gems = $hiera_gems + $gems

  $_gems.each |$title, $gem| {
    puppetserver_gem_repo::gem { $title:
      version            => $gem['version'],
      install_into_agent => $gem['install_into_agent'],
    }
  }

}
