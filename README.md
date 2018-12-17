# puppetserver_gem_repo

#### Table of Contents

1. [Description](#description)
1. [Setup](#setup)
1. [Usage](#usage)
1. [Reference](#reference)
1. [Limitations](#limitations)

## Description

This module will create a gem repository populated with the gems added to the puppetserver service on the master of masters (aka primary master).
This module will sync that gem repository to compile masters (and the replica master, if present) allowing this module to install those gems (and their dependencies) on the other masters via `puppetserver_gem_repo::gem` resources.
This is particularly valuable when the other masters do not have internet access.

## Setup

1. Install this module on the primary master.
1. Apply the `puppetserver_gem_repo` class to the `PE Master` node group via the Console.
1. Run `puppet agent -t` on the primary master.
1. Run `puppet agent -t` on the other masters.

## Usage

Install a puppetserver gem on the primary master, manually or via a manifest.

Specify the same gem as a `puppetserver_gem_repo::gem` resource on the other masters. For example:

```puppet
node 'compile-master-*.example.com' {
  puppetserver_gem_repo::gem {
    name               => 'puppet-resource_api',
    version            => '1.0.0',
    install_into_agent => true,
  }
}
```

To specify multiple gems, specify the `puppetserver_gem_repo::gems` class on the other masters, and specify the gems via Hiera. For example:

```puppet
node 'compile-master-*.example.com' {
  include puppetserver_gem_repo::gems
}
```

```yaml
---
 puppetserver_gem_repo::gems:
   hiera-eyaml:
     version:             2.1.0
     install_into_agent:  true
   jruby-ldap:
     install_into_agent:  false
```

## Reference

### Parameters

#### name

String. Required, with a default of the title of the resource.

The name of the puppetserver gem to install from the primary master.

#### version

String. Optional, with a default of 'present'.

The version of the puppetserver gem to install from the primary master.

#### install_into_agent

Boolean. Optional, with a default of false.

Whether to install the puppetserver gem into puppet in addition to the puppetserver service.

This is particularly valuable with 'hiera-eyaml' gem, allowing the `puppet lookup` command to use the 'eyaml' backend.

> Note: While this module was initially developed to sync the 'hiera-eyaml' gem, it is not limited to syncing that gem.

## Limitations

This module installs the 'builder' gem into puppet on the primary master. If your primary master does not have internet access, manually install the gem on the primary master before using this module. For example:

```shell
/opt/puppetlabs/puppet/bin/gem install builder --local builder-*.gem
```
