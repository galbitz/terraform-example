
resource "azurerm_public_ip" "control-ip" {
  name                         = "${var.namespace}-control-ip"
  location                     = "${azurerm_resource_group.rg.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "Dynamic"
  idle_timeout_in_minutes      = 30
}

resource "azurerm_network_interface" "control-nic" {
  name                = "${var.namespace}-control-nic"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "control-ip-config"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "10.0.0.5"
    public_ip_address_id          = "${azurerm_public_ip.control-ip.id}"
  }
}

resource "azurerm_virtual_machine" "control-vm" {
  name                         = "${var.namespace}-control-vm"
  location                     = "${azurerm_resource_group.rg.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  network_interface_ids        = ["${azurerm_network_interface.control-nic.id}"]
  primary_network_interface_id = "${azurerm_network_interface.control-nic.id}"
  vm_size                      = "${var.vmsize}"

  delete_os_disk_on_termination = true

  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.3"
    version   = "latest"
  }

  storage_os_disk {
    name          = "control-disk1"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "control-vm"
    admin_username = "${var.adminusername}"
    admin_password = "${var.adminpassword}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_virtual_machine_extension" "control-vm-extension" {
  name                 = "linuxext"
  location             = "${azurerm_resource_group.rg.location}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_machine_name = "${azurerm_virtual_machine.control-vm.name}"
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  depends_on           = ["azurerm_virtual_machine.control-vm", "azurerm_storage_blob.provision", "azurerm_storage_blob.assign_drives", "azurerm_storage_blob.ConfigureRemotingForAnsible", "azurerm_storage_blob.ansible_install_centos", "azurerm_storage_blob.webdeploypriv", "azurerm_storage_blob.provisionsh"]

  settings = <<SETTINGS
    {
        "fileUris": [
          "${azurerm_storage_account.storage.primary_blob_endpoint}${azurerm_storage_container.artifacts.name}/control/ansible_install_centos.sh",
          "${azurerm_storage_account.storage.primary_blob_endpoint}${azurerm_storage_container.artifacts.name}/control/provision.sh",
          "${azurerm_storage_account.storage.primary_blob_endpoint}${azurerm_storage_container.artifacts.name}/control/webdeploy.priv"
        ],
        "commandToExecute": "sh provision.sh"

    }
SETTINGS
}

data "azurerm_public_ip" "control-public-ip" {
  name                = "${azurerm_public_ip.control-ip.name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  depends_on          = ["azurerm_virtual_machine.control-vm"]
}

output "control-vm-ip_address" {
  value = "${data.azurerm_public_ip.control-public-ip.ip_address}"
}
