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

# Define any Azure resources to be created here. A simple resource group is shown here as a minimal example.
resource "azurerm_resource_group" "rg-tf-db-ai-demo" {
  name     = var.resource_group_name
  location = var.location
}


resource "azurerm_databricks_workspace" "this" {
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
  host = azurerm_databricks_workspace.this.workspace_url
}

resource "databricks_user" "my-user" {
  user_name    = "test-user@databricks.com"
  display_name = "Test User"
}