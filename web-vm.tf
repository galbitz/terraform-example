resource "azurerm_public_ip" "web-ip" {
  name                         = "${var.namespace}-web-ip"
  location                     = "${azurerm_resource_group.rg.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "Dynamic"
  idle_timeout_in_minutes      = 30
}

resource "azurerm_network_interface" "web-nic" {
  name                = "${var.namespace}-web-nic"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "web-ip-config"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "10.0.0.4"
    public_ip_address_id          = "${azurerm_public_ip.web-ip.id}"
  }
}

resource "azurerm_virtual_machine" "web-vm" {
  name                         = "${var.namespace}-web-vm"
  location                     = "${azurerm_resource_group.rg.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  network_interface_ids        = ["${azurerm_network_interface.web-nic.id}"]
  primary_network_interface_id = "${azurerm_network_interface.web-nic.id}"
  vm_size                      = "${var.vmsize}"

  delete_os_disk_on_termination = true

  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2012-R2-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name          = "web-disk1"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  storage_data_disk {
    name          = "web-disk2"
    disk_size_gb  = "40"
    lun           = 1
    create_option = "Empty"
  }

  os_profile {
    computer_name  = "web-vm"
    admin_username = "${var.adminusername}"
    admin_password = "${var.adminpassword}"
  }

  os_profile_windows_config {
    provision_vm_agent = true
  }
}

resource "azurerm_virtual_machine_extension" "web-vm-extension" {
  name                 = "winrm"
  location             = "${azurerm_resource_group.rg.location}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_machine_name = "${azurerm_virtual_machine.web-vm.name}"
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"
  depends_on           = ["azurerm_virtual_machine.web-vm", "azurerm_storage_blob.provision", "azurerm_storage_blob.assign_drives", "azurerm_storage_blob.ConfigureRemotingForAnsible", "azurerm_storage_blob.ansible_install_centos", "azurerm_storage_blob.webdeploypriv", "azurerm_storage_blob.webdeploypub"]

  settings = <<SETTINGS
    {
        "fileUris": [
          "${azurerm_storage_account.storage.primary_blob_endpoint}${azurerm_storage_container.artifacts.name}/web/provision.ps1",
          "${azurerm_storage_account.storage.primary_blob_endpoint}${azurerm_storage_container.artifacts.name}/web/assign_drives.ps1",
          "${azurerm_storage_account.storage.primary_blob_endpoint}${azurerm_storage_container.artifacts.name}/web/ConfigureRemotingForAnsible.ps1"
        ],
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File web/provision.ps1 -Azure"
        
    }
SETTINGS
}

data "azurerm_public_ip" "web-public-ip" {
  name                = "${azurerm_public_ip.web-ip.name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  depends_on          = ["azurerm_virtual_machine.web-vm"]
}

output "web-vm-ip_address" {
  value = "${data.azurerm_public_ip.web-public-ip.ip_address}"
}
