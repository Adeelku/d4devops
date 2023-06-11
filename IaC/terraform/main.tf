# Azure Provider configuration
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {
}

data "azurerm_client_config" "current" {}

# Use existing subnet where PE is to be created
data "azurerm_subnet" "subnet" {
  name                 = "iaas-workloads"
  virtual_network_name = "poc-vnet"
  resource_group_name  = "poc-vnet-rg"
}

module "workloads_resource_group"{
  source              = "../modules/resource-group"
  name                = var.resource_group_name
  location            = var.location
  business_unit       = var.business_unit
  environment_type    = var.environment
  tags                = var.tags
}

module "key-vault" {
    source = "../modules/security/keyvault"
    location                                      = module.workloads_resource_group.location
    resource_group_name                           = module.workloads_resource_group.name
    key_vault_name                                = var.key_vault_name
    key_vault_sku_pricing_tier                    = "premium"
    enable_purge_protection                       = false
    private_endpoint_resources_enabled            = []
    pe_network = {
        resource_group_name                       = var.pe_resource_group_name
        vnet_name                                 = var.vnet_name
        subnet_name                               = var.subnet_name
    }
    private_endpoint_name = "privatelink.vaultcore.azure.net"
    pe_resource_group_name = var.pe_resource_group_name

    # Access policies for users, you can provide list of Azure AD users and set permissions.
    # Make sure to use list of user principal names of Azure AD users.
    access_policies = [
        # Access policies for Azure AD Service Principlas
        # To enable this feature, provide a list of Azure AD SPN and set permissions as required.
        {
        azure_ad_service_principal_names = ["tf-sp", "very friendly name"]
        key_permissions                  = ["Backup", "Delete", "List", "Get"]
        secret_permissions               = ["Backup", "Delete", "List", "Get"]
        }
    ]
    tags = var.tags
}

module "data_lake" {
    source = "../modules/datalake"

    location             = module.workloads_resource_group.location
    resource_group_name  = module.workloads_resource_group.name
    storage_account_name = var.dtlk_strg_account_name
    tags                 = var.tags
    dtlk_file_name      = var.datalake_file_name
    properties = {
          dap = "200-basic-ml"
    }
    private_endpoint_name  = "private-endpoint"
    pe_resource_group_name = var.pe_resource_group_name
    pe_network = {
        resource_group_name                       = var.pe_resource_group_name
        vnet_name                                 = var.vnet_name
        subnet_name                               = var.subnet_name
    }
} 

module "storage" {
    source  = "../modules/storage-account"
    storage_account       = var.storage_account_name
    create_resource_group = false
    resource_group_name   = module.workloads_resource_group.name
    location              = module.workloads_resource_group.location
    environment_type      = var.environment 
    security_level        = var.security_level
    business_unit         = var.business_unit
    storage_type          = var.storage_type
    enable_advanced_threat_protection = var.enable_advanced_threat_protection
    containers_list = var.containers_list
    lifecycles = var.lifecycles
    tags = var.tags
    private_endpoint_resources_enabled = []
    encryption_scope_name = "microsoftmanaged"
    private_endpoint_name  = "privatelink.blob.core.windows.net"
    pe_resource_group_name = var.pe_resource_group_name
    pe_network = {
        resource_group_name                       = var.pe_resource_group_name
        vnet_name                                 = var.vnet_name
        subnet_name                               = var.subnet_name
    }
}
module "synapse_workspace" {
    source = "../modules/analytics/synapse"

    resource_group_name  = module.workloads_resource_group.name
    location = module.workloads_resource_group.location
    synapse_ws_name = var.synapse_ws_name
    vnet_id                 = var.vnet_name
    subnet_id               = data.azurerm_subnet.subnet.id
    adls_id                 = module.data_lake.id
    key_vault_id            = module.key-vault.id
    key_vault_name          = module.key-vault.name
    synadmin_username       = var.synadmin_username
    synadmin_password       = var.synadmin_password

    aad_login = {
        name = "azureuser@contoso.com"
        object_id = data.azurerm_client_config.current.object_id
        tenant_id = data.azurerm_client_config.current.tenant_id
  }
  workspace_firewall = {
    name     = "AllowAll"
    start_ip = "0.0.0.0"
    end_ip   = "255.255.255.255"
  } 
  private_endpoint_resources_enabled            = []
  private_endpoint_name  = "privatelink.azuresynapse.net"
  pe_resource_group_name = var.pe_resource_group_name
  pe_network = {
        resource_group_name                       = var.pe_resource_group_name
        vnet_name                                 = var.vnet_name
        subnet_name                               = var.subnet_name
    }
  tags = var.tags
}