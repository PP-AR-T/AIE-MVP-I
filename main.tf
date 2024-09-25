terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "1.37.1"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-terraform-github-actions"
    storage_account_name = "sappterraformga"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    use_oidc             = true
  }
}

provider "azurerm" {
  features {}
  use_oidc = true
}

provider "databricks" {
  host = azurerm_databricks_workspace.workspace.workspace_url
}

data "azurerm_client_config" "current" {}

###########
#FIRST BATCH
###########

# Define the resource group
resource "azurerm_resource_group" "rg-tf-db-ai-demo" {
  name     = var.resource_group_name
  location = var.location
}

###########
#SECOND BATCH
###########


# Define the Databricks module
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
  prefix                      = var.prefix
  depends_on                  = [null_resource.wait_for_rg]
}

# Reference the output variables from the databricks module
output "public_subnet_id" {
  value = module.databricks.public_subnet_id
}

output "private_subnet_id" {
  value = module.databricks.private_subnet_id
}