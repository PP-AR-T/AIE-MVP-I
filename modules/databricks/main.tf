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
  subnet_id                 = var.private_subnet_id                 # ID of the private subnet
  network_security_group_id = azurerm_network_security_group.example.id
}

resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = var.public_subnet_id                  # ID of the public subnet
  network_security_group_id = azurerm_network_security_group.example.id
}
# Define a Network Security Group (NSG)
resource "azurerm_network_security_group" "example" {
  name                = "${var.prefix}-databricks-nsg"          # Name of the NSG
  location            = var.location   # Location of the NSG
  resource_group_name = var.resource_group_name    # Resource group for the NSG
}

resource "azurerm_databricks_workspace" "workspace" {
  location                      = var.location
  name                          = var.databricks_workspace_name
  resource_group_name           = var.resource_group_name
  sku                           = var.databricks_sku
  managed_resource_group_name   = var.managed_resource_group_name
  public_network_access_enabled = true #fixing checkov CKV_AZURE_158
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

provider "databricks" {
  host = azurerm_databricks_workspace.workspace.workspace_url
}

resource "databricks_user" "user" {
  user_name    = var.databricks_user_name
  display_name = var.databricks_display_name
}


