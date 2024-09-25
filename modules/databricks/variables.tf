variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be deployed"
  type        = string
}

variable "databricks_workspace_name" {
  description = "The name of the Databricks workspace"
  type        = string
}

variable "databricks_sku" {
  description = "The SKU for the Databricks workspace"
  type        = string
}

variable "managed_resource_group_name" {
  description = "The name of the managed resource group for Databricks"
  type        = string
}

variable "storage_account_name" {
  description = "The name of the storage account for Databricks"
  type        = string
}

variable "storage_account_sku_name" {
  description = "The SKU of the storage account for Databricks"
  type        = string
}

variable "databricks_user_name" {
  description = "The email of the Databricks user"
  type        = string
}

variable "databricks_display_name" {
  description = "The display name of the Databricks user"
  type        = string
}

variable "prefix" {
  description = "The Prefix used for all resources in this example"
}
# modules/databricks/variables.tf
