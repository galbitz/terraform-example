resource "azurerm_storage_account" "storage" {
  name                     = "${var.namespace}storage"
  resource_group_name      = "${azurerm_resource_group.rg.name}"
  location                 = "${azurerm_resource_group.rg.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "artifacts" {
  name                  = "${var.namespace}-artifacts"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  storage_account_name  = "${azurerm_storage_account.storage.name}"
  container_access_type = "container"
}

resource "azurerm_storage_blob" "provision" {
  name                   = "web/provision.ps1"
  resource_group_name    = "${azurerm_resource_group.rg.name}"
  storage_account_name   = "${azurerm_storage_account.storage.name}"
  storage_container_name = "${azurerm_storage_container.artifacts.name}"
  source                 = "c:\\dev\\worldengine\\bootstrap\\web\\provision.ps1"
  type                   = "block"
}

resource "azurerm_storage_blob" "assign_drives" {
  name                   = "web/assign_drives.ps1"
  resource_group_name    = "${azurerm_resource_group.rg.name}"
  storage_account_name   = "${azurerm_storage_account.storage.name}"
  storage_container_name = "${azurerm_storage_container.artifacts.name}"
  source                 = "c:\\dev\\worldengine\\bootstrap\\web\\assign_drives.ps1"
  type                   = "block"
}

resource "azurerm_storage_blob" "ConfigureRemotingForAnsible" {
  name                   = "web/ConfigureRemotingForAnsible.ps1"
  resource_group_name    = "${azurerm_resource_group.rg.name}"
  storage_account_name   = "${azurerm_storage_account.storage.name}"
  storage_container_name = "${azurerm_storage_container.artifacts.name}"
  source                 = "c:\\dev\\worldengine\\bootstrap\\web\\ConfigureRemotingForAnsible.ps1"
  type                   = "block"
}

resource "azurerm_storage_blob" "ansible_install_centos" {
  name                   = "control/ansible_install_centos.sh"
  resource_group_name    = "${azurerm_resource_group.rg.name}"
  storage_account_name   = "${azurerm_storage_account.storage.name}"
  storage_container_name = "${azurerm_storage_container.artifacts.name}"
  source                 = "c:\\dev\\worldengine\\bootstrap\\control\\ansible_install_centos.sh"
  type                   = "block"
}

resource "azurerm_storage_blob" "webdeploypriv" {
  name                   = "control/webdeploy.priv"
  resource_group_name    = "${azurerm_resource_group.rg.name}"
  storage_account_name   = "${azurerm_storage_account.storage.name}"
  storage_container_name = "${azurerm_storage_container.artifacts.name}"
  source                 = "c:\\dev\\worldengine\\bootstrap\\control\\webdeploy.priv"
  type                   = "block"
}

resource "azurerm_storage_blob" "webdeploypub" {
  name                   = "control/webdeploy.pub"
  resource_group_name    = "${azurerm_resource_group.rg.name}"
  storage_account_name   = "${azurerm_storage_account.storage.name}"
  storage_container_name = "${azurerm_storage_container.artifacts.name}"
  source                 = "c:\\dev\\worldengine\\bootstrap\\control\\webdeploy.pub"
  type                   = "block"
}

resource "azurerm_storage_blob" "provisionsh" {
  name                   = "control/provision.sh"
  resource_group_name    = "${azurerm_resource_group.rg.name}"
  storage_account_name   = "${azurerm_storage_account.storage.name}"
  storage_container_name = "${azurerm_storage_container.artifacts.name}"
  source                 = "c:\\dev\\worldengine\\bootstrap\\control\\provision.sh"
  type                   = "block"
}
