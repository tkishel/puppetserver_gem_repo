# puppetserver_gem_repo
#
# @summary Manage puppetserver jruby gems on the master of masters and other masters.
#
# @example
#   include puppetserver_gem_repo

class puppetserver_gem_repo {
  include puppetserver_gem_repo::conf

  if $puppetserver_gem_repo::conf::is_master_of_masters {
    include puppetserver_gem_repo::master_of_masters
  } else {
    include puppetserver_gem_repo::master
  }

}
