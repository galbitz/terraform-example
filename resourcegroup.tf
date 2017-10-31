resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.namespace}"
  location = "${var.location}"
}
