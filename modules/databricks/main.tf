resource "azurerm_databricks_workspace" "a_db_ws" {
  location            = "uksouth"
  name                = "db-workspace-demo"
  resource_group_name = var.resource_group_name
  sku                 = "trial"
  managed_resource_group_name = "db-managed-rg-demo"
  custom_parameters {
    storage_account_name = "sa_databricks-ppdemo"
    storage_account_sku_name = "Standard_LRS"
  }
}
provider "databricks" {
  host = azurerm_databricks_workspace.a_db_ws.workspace_url
}
resource "databricks_user" "my-user" {
  user_name    = "pp-test-user@databricks.com"
  display_name = "PP-Test User"
}