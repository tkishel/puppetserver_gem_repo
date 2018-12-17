# Configuration shared by puppetserver_gem_repo classes and types.
#
# Note: FM-7145
#
# puppetserver_gem_home            = '/opt/puppetlabs/server/data/puppetserver/jruby-gems'
# puppetserver_vendored_jruby_gems = '/opt/puppetlabs/server/data/puppetserver/vendored-jruby-gems'
# puppet_vendored_gems             = '/opt/puppetlabs/puppet/lib/ruby/vendor_gems'
# puppetserver_gem_path            = [puppetserver_gem_home, puppetserver_vendored_jruby_gems, puppet_vendored_gems]
#
# @api private

class puppetserver_gem_repo::conf (

  $install_builder_gem = true

) {

  $puppet_ca_certificate        = $::settings::localcacert

  $puppet_gem_command           = '/opt/puppetlabs/puppet/bin/gem'
  $puppet_curl_command          = '/opt/puppetlabs/puppet/bin/curl'
  $puppetserver_gem_command     = '/opt/puppetlabs/bin/puppetserver gem'
  $puppetserver_gem_directories = "${::settings::vardir}/*/gems"
  $puppet_shared_gem_directory  = '/opt/puppetlabs/puppet/lib/ruby/vendor_gems'
  $jruby_gems_cache             = "${::settings::vardir}/jruby-gems/cache"

  $repository                   = '/opt/puppetlabs/server/data/packages/public/puppetserver_gems'
  $archive                      = 'puppetserver_gem_repo.tgz'
  $repository_archive           = "${repository}/${archive}"

  $server                       = $::settings::server
  $is_master_of_masters         = ($::fqdn == $server)

}
