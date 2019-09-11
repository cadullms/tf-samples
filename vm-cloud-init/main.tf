# To use remote state, see https://docs.microsoft.com/en-us/azure/terraform/terraform-backend 

# terraform {
#   backend "azurerm" {
#     storage_account_name  = "tfstate5379"
#     container_name        = "tfstate"
#  }
#}

resource "azurerm_resource_group" "myterraformgroup" {
    name     = "${var.resource_group_name}"
    location = "${var.location}"

    tags = {
        environment = "Terraform Demo for VM with cloud-init template"
    }
}

# Shared Resources =======================================================

resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "myVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "${azurerm_resource_group.myterraformgroup.location}"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

    tags = {
        environment = "Terraform Demo"
    }
}

resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "myNetworkSecurityGroup"
    location            = "${azurerm_resource_group.myterraformgroup.location}"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTP8080"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTP8081"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8081"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Terraform Demo"
    }
}

resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "mySubnet"
    resource_group_name  = "${azurerm_resource_group.myterraformgroup.name}"
    virtual_network_name = "${azurerm_virtual_network.myterraformnetwork.name}"
    address_prefix       = "10.0.1.0/24"
}

resource "azurerm_subnet_network_security_group_association" "mynsgassociation" {
  subnet_id                 = "${azurerm_subnet.myterraformsubnet.id}"
  network_security_group_id = "${azurerm_network_security_group.myterraformnsg.id}"
}

resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${azurerm_resource_group.myterraformgroup.name}"
    }

    byte_length = 8
}

resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = "${azurerm_resource_group.myterraformgroup.name}"
    location                    = "${azurerm_resource_group.myterraformgroup.location}"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "Terraform Demo"
    }
}

# Resources per VM-Instance ======================================

resource "azurerm_public_ip" "myterraformpublicip" {
    count = "${var.vmcount}"
    name                         = "myPublicIP-${count.index}"
    location                     = "${azurerm_resource_group.myterraformgroup.location}"
    resource_group_name          = "${azurerm_resource_group.myterraformgroup.name}"
    allocation_method = "Dynamic"

    tags = {
        environment = "Terraform Demo"
    }
}

resource "azurerm_network_interface" "myterraformnic" {
    count = "${var.vmcount}"
    name                      = "myNIC-${count.index}"
    location                  = "${azurerm_resource_group.myterraformgroup.location}"
    resource_group_name       = "${azurerm_resource_group.myterraformgroup.name}"
    
    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.myterraformsubnet.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${element(azurerm_public_ip.myterraformpublicip.*.id,count.index)}"
    }

    tags = {
        environment = "Terraform Demo"
    }
}

data "template_file" "cloudconfig" {
  count = "${var.vmcount}"
  template = "${file("${var.cloudconfig_file}")}"
  vars = {
    admin_username = "${var.admin_username}"
    hello_world_text = "${var.hello_world_text}.${count.index}"
  }
}

data "template_cloudinit_config" "config" {
  count = "${var.vmcount}"
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = "${element(data.template_file.cloudconfig.*.rendered,count.index)}"
  }
}

resource "azurerm_virtual_machine" "myterraformvm" {
    count = "${var.vmcount}"
    name                  = "myVM-${count.index}"
    location              = "${azurerm_resource_group.myterraformgroup.location}"
    resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"
    network_interface_ids = ["${element(azurerm_network_interface.myterraformnic.*.id,count.index)}"]
    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = "myOsDisk-${count.index}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "myvm${count.index}"
        admin_username = "${var.admin_username}"
        custom_data    = "${element(data.template_cloudinit_config.config.*.rendered,count.index)}"
    }

    os_profile_linux_config {
      disable_password_authentication = true

      ssh_keys {
        path     = "/home/${var.admin_username}/.ssh/authorized_keys"
        key_data = "${var.ssh_public_key_data}"
      }
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
    }

    tags = {
        environment = "Terraform Demo"
    }
}