Workstream
==========

About
-----
This repo contains an example set of [Terraform](https://www.terraform.io/) modules, [Packer](https://www.packer.io/) templates, [Ansible](https://www.ansible.com/) Playbooks, [Chef](https://www.chef.io/chef/) Recipes and [Puppet](https://puppet.com/) manifests that provision and configure a set of machines in AWS.  It's designed to help coders get started in DevOps.

Getting started
---------------

This repo is designed to be a simple starting point for infrastructure-as-code projects.  Invariably, you'll need some tools to build that infrastructure and credentials to secure access to it.  The setup of both is described here:

* [Getting set up guide [.md]](/docs/getting_set_up.md) - how to set up your environment for instantiating infrastructure using the code in this repo

We use `terragrunt` as an optional wrapper for `terraform`.  The two are used interchangably here.  If you've used the default key name and path (described [above](/docs/getting_set_up.md)), then to see what terraform plans to build out in the default region (eu-west-2):
```
cd terraform/
terragrunt plan
```

If it seems sensible, apply it:
```
terragrunt apply
```

Look at what you've created in the AWS console!

Shutting down
-------------

Most important of all while developing IAC, clear it up afterwards:
```
terragrunt destroy
```
Also be aware that while `terragrunt destroy` will remove all the instantiated hosts/security groups/subnets/VPCs etc., it will not remove everything.  You'll need to use the AWS console to manually deregister/delete:

* Volumes belonging to hosts instantiated by Terraform
  * After multiple terraform-plan-apply-destroy cycles, you can easily accumulate a few dozen volumes.  These will persist (at a cost) unless explicitly removed.
* AMIs produced by Packer
  * Also the Snapshots that Packer produces as an intermediate file.

File structure
--------------
This repo is organised at the top-level by technology.

* [/bin](/bin) - a few scripts to hold useful commands for reference
* [/docs](/docs) - markdown-formatted documents describing the examples in this repo

Image creation and orchestration

* [/packer](/packer) - a set of Packer templates
  * `centos_updates.json` - create updated AMI image based on CentOS 7 (cross-region)
  * `remote_provisioning.json` - create AMI image based on CentOS 7, including this repo with all pre-requisites installed

Config management

* [/ansible](/ansible) - an ansible control folder (```/etc/ansible```) containing an array of playbooks and roles
  * [roles](/ansible/roles)
    * [common](/ansible/roles/common) - a simple common role shared across all playbooks
* [/puppet](/puppet) - a Puppet control folder (```/etc/puppet```) containing an array of environments and modules
  * [environments](/puppet/environments)
    * [workstream](/puppet/environments/workstream) - the main workstream template environment
      * [manifests](/puppet/environments/workstream/manifests) - puppet manifests
        * `host-<hostname>.pp` - puppet masterless manifest, called directly with puppet apply
        * `site.pp` - general environment master manifest, server via Puppet master
      * [modules](/puppet/environments/workstream/modules) - environment specific modules
  * [modules](/puppet/modules) - community modules

Provisioning

* [/terraform](/terraform) - a collection of modules to provision machines, linked from single root module [main.tf](/terraform/main.tf). 
  * [ansible](/terraform/ansible) - a terraform module to set up a generic host and invoke ansible on it locally 
  * [aws_background](/terraform/aws_background) - a terraform module to set up a basic AWS environment
  * [pack_amis](/terraform/pack_amis) - a terraform module to invoke packer
  * [packer](/terraform/packer) - a terraform module to instantiate a host from a packed machine image
  * [puppetmless](/terraform/puppetmless) - a terraform module to set up a generic host and invoke puppet apply on it locally 
  * [puppetmastered](/terraform/puppetmastered) - a terraform module to set up a generic host, connect it to a puppetmaster and set up a puppet agent for repeat runs 

Testing
-------
To run the integration test suite in /tests/awspec, you need install the gems
`bundle install`

The test run command is as simple as `bundle exec rake spec` after a successful `terraform apply`, but you need explicitly set the region environment variable:
```
AWS_DEFAULT_REGION="eu-west-2" bundle exec rake spec
```

Security
--------
All hosts are built with SELinux enabled (enforcing).  While every effort has been made to build these examples in the right way, new vectors are being discovered everyday.  Keep yourself safe by validating hashes for everything you download and run, locking down your environment with passworded rotated keys, etc.  Read the [LICENSE](/LICENSE) carefully.

Documentation
-------------

We've taken the same simple approach to documentation.  It's all in markdown-formatted .md files, linked directly from this README.md.

* [Getting set up [.md]](/docs/getting_set_up.md) - guide to setting up your terraform machine (local or remote)
  * [Pre-requisites [.md]](/docs/pre_requisites.md)
  * [AWS permissions [.md]](/docs/aws_permissions.md)
  * [Remote provisioning [.md]](/docs/remote_provisioning.md)
* [Complete: Provisioned environment [.md]](/docs/provisioned_environment.md) - details of all the hosts created by workstream

Playspace
---------

Once you've built (and destroyed) a bunch of machines using the example (root terraform module), you might like to start hacking around your own manifest.  [/playspace](/playspace) is a basic template that gives you a starting point for your own experiments.  The root module in playspace (main.tf) is set up with terragrunt to access all the other terraform modules, so you can cut-and-paste sections of the [examples main.tf](/terraform/main.tf), then run:

```
cd playspace/
terragrunt plan
terragrunt apply
terragrunt destroy
```

Version 2.0
-------
This project started out as a training course that I [designed and ran at the Department of Work and Pensions](https://github.com/dwp/devops-workstream).  Since leaving it's no longer being maintained.  In response to a few requests, I'll try to find time to continue to develop it open-source.  If you've got questions about the course or using it to train your team, please [get in touch](http://www.lightenna.com/contact).
