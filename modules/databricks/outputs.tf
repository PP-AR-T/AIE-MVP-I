output "databricks_workspace_url" {
  description = "The URL of the Databricks workspace"
  value       = azurerm_databricks_workspace.workspace.workspace_url
}
