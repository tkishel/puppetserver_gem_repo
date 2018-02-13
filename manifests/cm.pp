# Create a local gem repository on compile masters from the master of masters.
# @api public

class puppetserver_gem_repo::cm (

  $private_class = 'do not directly apply this class',

) {

  $ca_certificate     = $puppetserver_gem_repo::conf::puppet_ca_certificate
  $curl_command       = $puppetserver_gem_repo::conf::puppet_curl_command
  $repository         = $puppetserver_gem_repo::conf::repository
  $repository_archive = $puppetserver_gem_repo::conf::repository_archive
  $curl_url           = "https://${servername}:8140/packages/puppetserver_gems/${puppetserver_gem_repo::conf::archive}"
  $curl_options       = "--cacert ${ca_certificate} -f -s -R -z ${repository_archive} -w '%{http_code}'"

  file { $repository :
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  exec { 'puppetserver_gem_repo download' :
    command => "cp -f -p ${repository_archive}.download ${repository_archive}",
    path    => '/usr/bin:/usr/sbin:/bin',
    onlyif  => "${curl_command} ${curl_options} -o ${repository_archive}.download ${curl_url} | grep 200",
    notify  => Exec['puppetserver_gem_repo extract'],
    require => File[$repository],
  }

  exec { 'puppetserver_gem_repo extract' :
    command => "tar --directory=${repository} -xzf ${repository_archive}",
    path    => '/usr/bin:/usr/sbin:/bin',
    creates => "${repository}/ruby/gems",
    require => File[$repository],
  }

}
