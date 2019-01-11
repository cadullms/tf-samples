# tf-samples
Terraform samples for provisioning Azure resources

## Getting started
* [Install and configure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure?toc=%2Fen-us%2Fazure%2Fterraform%2Ftoc.json&bc=%2Fen-us%2Fazure%2Fbread%2Ftoc.json) - Either by using cloud shell (recommend for easiest start as terraform is preinstalled in the cloud shell) or installing it locally.
* [First VM example](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-create-complete-vm?toc=%2Fen-us%2Fazure%2Fterraform%2Ftoc.json&bc=%2Fen-us%2Fazure%2Fbread%2Ftoc.json) - Note that this example uses a file for providing Azure connection information. Ideally, you should use [environment variables](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure?toc=%2Fen-us%2Fazure%2Fterraform%2Ftoc.json&bc=%2Fen-us%2Fazure%2Fbread%2Ftoc.json#configure-terraform-environment-variables) instead.
* Install [VS Code](https://code.visualstudio.com/) and the [Terraform Extension](https://docs.microsoft.com/en-us/azure/terraform/terraform-vscode-extension) for the best editing experience. 

## Samples in this repository

* [vm-cloud-init](./vm-cloud-init/README.md) - Based on the Linux VM sample mentioned above, but featuring cloud-init to configure the machine and allowing for one or many machines be created at once.
* [aks-terraform](./aks-terraform/README.md) - Building a Kubernetes cluster with AKS (TBD) 

## Useful links

* [Working with remote state](https://docs.microsoft.com/en-us/azure/terraform/terraform-backend)
* [Working with outputs](https://www.terraform.io/docs/commands/output.html)
* [Official terraform docker image](https://hub.docker.com/r/hashicorp/terraform/)
* [Run local script from within terraform](https://www.terraform.io/docs/provisioners/local-exec.html)
* [Run remote script from within terraform](https://www.terraform.io/docs/provisioners/remote-exec.html)
* [Using “logic” in Terraform](https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9)
* [Interpolation functions](https://www.terraform.io/docs/configuration/interpolation.html)
