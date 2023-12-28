# Project

Deployment rancher Rke2

## Description

The propose project is create a simple environment for testing, the project is segmented for
provisioning a cluster with rke2 in local machine with different methods.

The project use a files and documentation from resources rancher

* https://registry.terraform.io/modules/rancher/rke2-download/github/latest
* https://registry.terraform.io/modules/rancher/rke2-install/null/latest

## Getting Started

### Dependencies

* Terraform.
* Vagrant


### Installing

* [Link](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) install terraform pack
* [Link](https://developer.hashicorp.com/vagrant/docs/installation) install terraform pack
* [Link] (https://www.virtualbox.org/wiki/Downloads) install virtual box

### Run project

#### Provision local machines with vagrant
```
vagrant up

```

#### Provision configuration files with terraform
```
terraform init
terraform plan
terraform apply
```
