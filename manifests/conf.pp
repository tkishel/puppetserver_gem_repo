# TODO: Replace hard-coded paths with configured settings.

#
# @api private

class puppetserver_gem_repo::conf (

  $private_class = 'do not directly apply this class',

) {

  $puppet_ca_certificate    = $::settings::localcacert
  $puppet_gem_command       = '/opt/puppetlabs/puppet/bin/gem'
  $puppet_curl_command      = '/opt/puppetlabs/puppet/bin/curl'
  $puppetserver_gem_command = '/opt/puppetlabs/bin/puppetserver gem'
  $jruby_gem_cache          = "${::settings::vardir}/jruby-gems/cache"
  $jruby_gems               = "${::settings::vardir}/jruby-gems/gems"
  $repository               = '/opt/puppetlabs/server/data/packages/public/puppetserver_gems'
  $archive                  = 'rubygems.tgz'
  $repository_archive       = "${repository}/${archive}"

  $is_master_of_masters     = ($::fqdn == $servername)

}
