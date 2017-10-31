
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
  source             = "c:\\dev\\worldengine\\bootstrap\\web\\provision.ps1"
  type = "block"
}

resource "azurerm_storage_blob" "assign_drives" {
  name                   = "web/assign_drives.ps1"
  resource_group_name    = "${azurerm_resource_group.rg.name}"
  storage_account_name   = "${azurerm_storage_account.storage.name}"
  storage_container_name = "${azurerm_storage_container.artifacts.name}"
  source             = "c:\\dev\\worldengine\\bootstrap\\web\\assign_drives.ps1"
  type = "block"
}

resource "azurerm_storage_blob" "ConfigureRemotingForAnsible" {
  name                   = "web/ConfigureRemotingForAnsible.ps1"
  resource_group_name    = "${azurerm_resource_group.rg.name}"
  storage_account_name   = "${azurerm_storage_account.storage.name}"
  storage_container_name = "${azurerm_storage_container.artifacts.name}"
  source             = "c:\\dev\\worldengine\\bootstrap\\web\\ConfigureRemotingForAnsible.ps1"
  type = "block"
}

resource "azurerm_storage_blob" "ansible_install_centos" {
  name                   = "control/ansible_install_centos.sh"
  resource_group_name    = "${azurerm_resource_group.rg.name}"
  storage_account_name   = "${azurerm_storage_account.storage.name}"
  storage_container_name = "${azurerm_storage_container.artifacts.name}"
  source             = "c:\\dev\\worldengine\\bootstrap\\control\\ansible_install_centos.sh"
  type = "block"
}

resource "azurerm_storage_blob" "webdeploypriv" {
  name                   = "control/webdeploy.priv"
  resource_group_name    = "${azurerm_resource_group.rg.name}"
  storage_account_name   = "${azurerm_storage_account.storage.name}"
  storage_container_name = "${azurerm_storage_container.artifacts.name}"
  source             = "c:\\dev\\worldengine\\bootstrap\\control\\webdeploy.priv"
  type = "block"
}

resource "azurerm_storage_blob" "webdeploypub" {
  name                   = "control/webdeploy.pub"
  resource_group_name    = "${azurerm_resource_group.rg.name}"
  storage_account_name   = "${azurerm_storage_account.storage.name}"
  storage_container_name = "${azurerm_storage_container.artifacts.name}"
  source             = "c:\\dev\\worldengine\\bootstrap\\control\\webdeploy.pub"
  type = "block"
}

# output "url2" {
#   value = "${azurerm_storage_blob.firstfile.url}"
# }

output "url" {
  value = "${azurerm_storage_account.storage.primary_blob_endpoint}"
}

output "token" {
  value = "${azurerm_storage_account.storage.primary_access_key}"
}

# resource "null_resource" "upload" {
#   provisioner "local-exec" {
#     command = "${path.module}\\upload.ps1 -ArtifactStagingDirectory C:\\dev\\WorldEngine\\bootstrap -StorageContainerName ${azurerm_storage_container.artifacts.name} -StorageAccountName ${azurerm_storage_account.storage.name}"
#     interpreter = ["PowerShell", "-Command"]
#   }
#     depends_on = ["azurerm_storage_container.artifacts"]
# }

# output "token" {
#     value = "${file("token.txt")}"
#     depends_on = ["null_resource.upload"]
# }


# data "azurerm_storage_container" "prop" {
#   name                = "${azurerm_storage_container.artifacts.name}"
#   resource_group_name = "${azurerm_resource_group.rg.name}"
#   #depends_on          = ["azurerm_virtual_machine.web-vm"]
# }

# output "prop" {
#    value = "${azurerm_storage_container.artifacts.properties}"
#  }

