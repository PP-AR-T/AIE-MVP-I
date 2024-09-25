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
}

provider "azurerm" {
  features {}
  use_oidc = true
}

provider "databricks" {
  host = azurerm_databricks_workspace.workspace.workspace_url
}

resource "azurerm_virtual_network" "example" {
  name                = "${var.prefix}-databricks-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "public" {
  name                 = "${var.prefix}-public-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "${var.prefix}-databricks-del"

    service_delegation {
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
      ]
      name = "Microsoft.Databricks/workspaces"
    }
  }
}

resource "azurerm_subnet" "private" {
  name                 = "${var.prefix}-private-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]

  delegation {
    name = "${var.prefix}-databricks-del"

    service_delegation {
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
      ]
      name = "Microsoft.Databricks/workspaces"
    }
  }
}
# Associate a Network Security Group (NSG) with the private subnet
resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = azurerm_subnet.private.id # ID of the private subnet
  network_security_group_id = azurerm_network_security_group.example.id
}

resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = azurerm_subnet.public.id # ID of the public subnet
  network_security_group_id = azurerm_network_security_group.example.id
}
# Define a Network Security Group (NSG)
resource "azurerm_network_security_group" "example" {
  name                = "${var.prefix}-databricks-nsg" # Name of the NSG
  location            = var.location                   # Location of the NSG
  resource_group_name = var.resource_group_name        # Resource group for the NSG
}

resource "azurerm_databricks_workspace" "workspace" {
  location                    = var.location
  name                        = var.databricks_workspace_name
  resource_group_name         = var.resource_group_name
  sku                         = var.databricks_sku
  managed_resource_group_name = var.managed_resource_group_name
  #checkov:skip=CKV_AZURE_158: I set up a private vnet for that???
  public_network_access_enabled = true
  #checkov:skip=CKV2_AZURE_48: No need for dbfs encryption at this point
  custom_parameters {
    storage_account_name     = var.storage_account_name
    storage_account_sku_name = var.storage_account_sku_name
    no_public_ip             = true
    public_subnet_name       = azurerm_subnet.public.name
    private_subnet_name      = azurerm_subnet.private.name
    virtual_network_id       = azurerm_virtual_network.example.id

    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.public.id
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.private.id
  }

  tags = {
    Environment = "Demo Sandbox"
    Pricing     = "Trial SKU"
  }
}

resource "databricks_user" "user" {
  user_name    = var.databricks_user_name
  display_name = var.databricks_display_name
}


resource "databricks_cluster" "demo-cluster" {
  cluster_name            = "demo-cluster"
  spark_version           = "15.4.x-cpu-ml-scala2.12"
  node_type_id            = "Standard_DS3_v2"
  autotermination_minutes = 30
  policy_id               = "0007302AE31343DE"
  data_security_mode      = "NONE"
  runtime_engine          = "PHOTON"

  autoscale {
    min_workers = 1
    max_workers = 2
  }

  azure_attributes {
    first_on_demand    = 1
    availability       = "SPOT_WITH_FALLBACK_AZURE"
    spot_bid_max_price = -1
  }

}
