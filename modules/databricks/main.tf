# Define any Azure resources to be created here. A simple resource group is shown here as a minimal example.
resource "azurerm_resource_group" "rg-tf-db-ai-demo" {
  name     = var.resource_group_name
  location = var.location
}

module "databricks" {
  source = "./modules/databricks"

  resource_group_name         = var.resource_group_name
  location                    = var.location
  databricks_workspace_name   = var.databricks_workspace_name
  databricks_sku              = var.databricks_sku
  managed_resource_group_name = var.managed_resource_group_name
  storage_account_name        = var.storage_account_name
  storage_account_sku_name    = var.storage_account_sku_name
  databricks_user_name        = var.databricks_user_name
  databricks_display_name     = var.databricks_display_name
}