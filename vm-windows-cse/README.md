# vm-windows-cse

Creating Windows VMs using the [Custom Script Extension](https://www.terraform.io/docs/providers/azurerm/r/virtual_machine_extension.html). See [this post on differnt init options](http://teknews.cloud/bootstrapping-azure-vms-with-terraform/) as well.

This is meant to be used for docker, thus we are using the pre-baked SKU for this (2016-Datacenter-with-Containers).

We will eventually use an init script to start a docker swarm.

