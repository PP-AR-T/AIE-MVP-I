resource "azurerm_databricks_workspace" "workspace" {
  location                      = var.location
  name                          = var.databricks_workspace_name
  resource_group_name           = var.resource_group_name
  sku                           = var.databricks_sku
  managed_resource_group_name   = var.managed_resource_group_name
  public_network_access_enabled = false #fixing checkov CKV_AZURE_158
  #checkov:skip=CKV2_AZURE_48: No need for dbfs encription at this point
  custom_parameters {
    storage_account_name     = var.storage_account_name
    storage_account_sku_name = var.storage_account_sku_name
  }
}

provider "databricks" {
  host = azurerm_databricks_workspace.workspace.workspace_url
}

resource "databricks_user" "user" {
  user_name    = var.databricks_user_name
  display_name = var.databricks_display_name
}
