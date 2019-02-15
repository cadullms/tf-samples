resource "azurerm_subnet" "aks_jump" {
  name                 = "aks-jump-subnet"
  resource_group_name  = "${azurerm_resource_group.aks_rg.name}"
  virtual_network_name = "${azurerm_virtual_network.aks_vnet.name}"
  address_prefix       = "10.0.6.0/28"
}

resource "azurerm_public_ip" "aks_jumphost_public_ip" {
    name                         = "aks-jumphost-public-ip"
    location                     = "${azurerm_resource_group.aks_rg.location}"
    resource_group_name          = "${azurerm_resource_group.aks_rg.name}"
    allocation_method = "Dynamic"

    tags {
        environment = "${var.environment_name}"
    }
}

resource "azurerm_network_interface" "aks_jumphost_nic" {
    name                      = "aks-jumphost-nic"
    location                  = "${azurerm_resource_group.aks_rg.location}"
    resource_group_name       = "${azurerm_resource_group.aks_rg.name}"
    
    ip_configuration {
        name                          = "aks-jumphost-nic-config"
        subnet_id                     = "${azurerm_subnet.aks_jump.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.aks_jumphost_public_ip.id}"
    }

    tags {
        environment = "${var.environment_name}"
    }
}

data "template_cloudinit_config" "aks_jumphost_config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = "${file("cloud-init.txt")}"
  }
}

resource "azurerm_virtual_machine" "aks_jumphost" {
    name                  = "aks-jumphost"
    location              = "${azurerm_resource_group.aks_rg.location}"
    resource_group_name   = "${azurerm_resource_group.aks_rg.name}"
    network_interface_ids = ["${azurerm_network_interface.aks_jumphost_nic.id}"]
    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = "aks-jumphost-os-disk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS" #xenial - if changed, change as well in cloud-init.txt
        version   = "latest"
    }

    os_profile {
        computer_name  = "aks-jumphost"
        admin_username = "${var.jumphost_admin_username}"
        custom_data    = "${data.template_cloudinit_config.aks_jumphost_config.rendered}"
    }

    os_profile_linux_config {
      disable_password_authentication = true

      ssh_keys {
        path     = "/home/${var.jumphost_admin_username}/.ssh/authorized_keys"
        key_data = "${var.jumphost_admin_ssh_public_key_data}"
      }
    }

    tags {
        environment = "${var.environment_name}"
    }
}