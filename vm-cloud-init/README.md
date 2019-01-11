# vm-cloud-init

Terraform config based on the [Linux VM sample from the Azure docs](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-create-complete-vm?toc=%2Fen-us%2Fazure%2Fterraform%2Ftoc.json&bc=%2Fen-us%2Fazure%2Fbread%2Ftoc.json), but featuring [cloud-init](https://cloud-init.io/) to configure the machine and allowing for one to many machines be created at once (see the `count` variable).

The cloud-init configuration in this sample goes into [cloudconfig.tpl](cloudconfig.tpl). Because it is a terraform template, variables can be used inside the template, to parameterize the values for each VM.

The initial cloud-init code was taken from [VM Scaleset with cloud-init module](https://github.com/Azure/terraform-azurerm-vmss-cloudinit).

