require 'spec_helper'

describe 'puppetserver_gem_repo' do
  let(:pre_condition) do
    "service { 'pe-puppetserver':
       ensure => running,
    }"
  end

  let(:params) do
    {
      gem:                 'hiera-eyaml',
      version:             '1.2.3',
      install_into_puppet: true,
    }
  end

  context 'on a master of masters, with all parameters' do
    let(:facts) do
      {
        fqdn:              'master.example.com',
        servername:        'master.example.com',
        pe_server_version: '2016.4.9',
      }
    end

    it { is_expected.to contain_puppetserver_gem_repo__gem('hiera-eyaml') }

    it { is_expected.to contain_class('puppetserver_gem_repo::conf') }

    it { is_expected.to contain_class('puppetserver_gem_repo::mom') }
    it { is_expected.to contain_package('puppet_gem builder') }
    it { is_expected.to contain_exec('puppetserver_gem_repo generate_index') }
    it { is_expected.to contain_exec('puppetserver_gem_repo archive') }

    it {
      is_expected.to contain_package('puppet_gem hiera-eyaml').with(
        'ensure'   => '1.2.3',
        'provider' => 'puppet_gem',
      )
    }
  end

  context 'on a compile master, with all parameters' do
    let(:facts) do
      {
        fqdn:              'master.example.com',
        servername:        'compile.example.com',
        pe_server_version: '2016.4.9',
      }
    end

    it { is_expected.to contain_puppetserver_gem_repo__gem('hiera-eyaml') }

    it { is_expected.to contain_class('puppetserver_gem_repo::conf') }

    it { is_expected.to contain_class('puppetserver_gem_repo::cm') }
    it { is_expected.to contain_exec('puppetserver_gem_repo download') }
    it { is_expected.to contain_exec('puppetserver_gem_repo extract') }

    # it {
    #  is_expected.to contain_exec('puppetserver install gem hiera-eyaml').with(
    #    'unless' => 'ls /opt/puppetlabs/server/data/puppetserver/jruby-gems/specifications/hiera-eyaml-1.2.3.gemspec 1>/dev/null 2>&1',
    #  )
    # }
    it {
      is_expected.to contain_package('puppet_gem hiera-eyaml').with(
        'ensure'   => '1.2.3',
        'provider' => 'puppet_gem',
      )
    }
  end
end
