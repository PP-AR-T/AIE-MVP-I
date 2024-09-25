terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0"
    }
  }

  # Update this block with the location of your terraform state file
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

data "azurerm_client_config" "current" {}

# Define any Azure resources to be created here. A simple resource group is shown here as a minimal example.
resource "azurerm_resource_group" "rg-tf-db-ai-demo" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_role_definition" "custom_role" {
  name        = "Custom Role for Role Assignment"
  scope       = azurerm_resource_group.rg-tf-db-ai-demo.id
  description = "Custom role to allow role assignments"
  permissions {
    actions = [
      "Microsoft.Authorization/roleAssignments/write",
      "Microsoft.Authorization/roleAssignments/read"
    ]
    not_actions = []
  }
  assignable_scopes = [azurerm_resource_group.rg-tf-db-ai-demo.id]
}

resource "null_resource" "wait_for_rg" {

  provisioner "local-exec" {
    command = <<EOT
      while ! az group show --name rg-tf-db-ai-demo --output none; do
        echo "Waiting for resource group to be available..."
        sleep 10
      done
      echo "Resource group is available."
    EOT
  }
}

# main.tf

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
}

# Reference the output variables from the databricks module
output "public_subnet_id" {
  value = module.databricks.public_subnet_id
}

output "private_subnet_id" {
  value = module.databricks.private_subnet_id
}