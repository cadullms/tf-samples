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
}

# Shared Resources =======================================================

resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "myVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "${azurerm_resource_group.myterraformgroup.location}"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
}

resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "myNetworkSecurityGroup"
    location            = "${azurerm_resource_group.myterraformgroup.location}"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

    security_rule {
        name                       = "RDP"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "3389"
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

# Resources per VM-Instance ======================================

resource "azurerm_public_ip" "myterraformpublicip" {
    count = "${var.vm_count}"
    name                         = "myPublicIP-${count.index}"
    location                     = "${azurerm_resource_group.myterraformgroup.location}"
    resource_group_name          = "${azurerm_resource_group.myterraformgroup.name}"
    allocation_method = "Dynamic"

}

resource "azurerm_network_interface" "myterraformnic" {
    count = "${var.vm_count}"
    name                      = "myNIC-${count.index}"
    location                  = "${azurerm_resource_group.myterraformgroup.location}"
    resource_group_name       = "${azurerm_resource_group.myterraformgroup.name}"
    
    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.myterraformsubnet.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${element(azurerm_public_ip.myterraformpublicip.*.id,count.index)}"
    }

}

data "template_file" "init_script" {
  count = "${var.vm_count}"
  template = "${file("${var.init_script_file}")}"

  vars = {
    admin_username = "${var.admin_username}"
    hello_world_text = "${var.hello_world_text}.${count.index}"
  }
}

resource "azurerm_virtual_machine" "myterraformvm" {
    count = "${var.vm_count}"
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
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2016-Datacenter-with-Containers"
        version   = "latest"
    }

    os_profile {
        computer_name  = "myvm${count.index}"
        admin_username = "${var.admin_username}"
        admin_password = "${var.admin_password}"
        custom_data    = "${element(data.template_file.init_script.*.rendered,count.index)}"
    }

    os_profile_windows_config {
        provision_vm_agent = true
    }
}

resource "azurerm_virtual_machine_extension" "myvmext" {
  
  count                = "${var.vm_count}"
  name                 = "myvmext${count.index}"
  location             = "${azurerm_resource_group.myterraformgroup.location}"
  resource_group_name  = "${azurerm_resource_group.myterraformgroup.name}"
  virtual_machine_name = "myvm-${count.index}"
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  depends_on           = ["azurerm_virtual_machine.myterraformvm"]
  # C:\AzureData\CustomData.bin is the path where the custom_data passed to the os_profile (see above) lands
  settings = <<SETTINGS
  {                        
    "commandToExecute": "powershell -command install-windowsfeature web-server;copy-item \"c:\\AzureData\\CustomData.bin\" \"c:\\AzureData\\CustomData.ps1\";\"c:\\AzureData\\CustomData.ps1\""
  }
SETTINGS
    
}
