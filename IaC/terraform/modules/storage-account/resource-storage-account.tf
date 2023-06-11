#---------------------------------------------------------
# Resource Group Creation or selection - Default is "false"
#----------------------------------------------------------
# data "azurerm_resource_group" "rgrp" {
#   count = var.create_resource_group == false ? 1 : 0
#   name  = var.resource_group_name
# }

# resource "azurerm_resource_group" "rg" {
#   count    = var.create_resource_group ? 1 : 0
#   name     = var.resource_group_name
#   location = var.location
#   tags     = var.tags
# }

#---------------------------------------------------------
# Storage Account Creation or selection 
#----------------------------------------------------------

resource "azurerm_storage_account" "storeacc" {
  name                                      = lower(join("",["CL",var.business_unit,var.security_level,var.storage_type]))
  # resource_group_name                       = local.resource_group_name
  # location                                  = local.location
  resource_group_name                       = var.resource_group_name
  location                                  = var.location
  account_kind                              = var.account_kind
  account_tier                              = local.account_tier
  account_replication_type                  = local.account_replication_type
  enable_https_traffic_only                 = true
  min_tls_version                           = var.min_tls_version
  nfsv3_enabled                             = var.nfsv3_enabled
  infrastructure_encryption_enabled         = var.infrastructure_encryption_enabled
  large_file_share_enabled                  = var.enable_large_file_share
  tags                                      = var.tags
  identity {
    type                                    = var.identity_ids != null ? "SystemAssigned, UserAssigned" : "SystemAssigned"
    identity_ids                            = var.identity_ids
  }

  dynamic "blob_properties" {
    for_each = ((var.account_kind == "BlockBlobStorage" || var.account_kind == "StorageV2") ? [1] : [])
    content {
      versioning_enabled = var.enable_versioning
      delete_retention_policy {
        days = var.blob_soft_delete_retention_days
      }
      container_delete_retention_policy {
        days = var.container_soft_delete_retention_days
      }
    }
  }

  dynamic "network_rules" {
    for_each = var.network_rules != null ? ["true"] : []
    content {
      default_action                        = "Deny"
      bypass                                = var.network_rules.bypass
      ip_rules                              = var.network_rules.ip_rules
      virtual_network_subnet_ids            = var.network_rules.subnet_ids
    }
  }
}

## azure reference https://docs.microsoft.com/en-us/azure/storage/common/infrastructure-encryption-enable?tabs=portal
resource "azurerm_storage_encryption_scope" "scope" {
  name                                      = var.encryption_scope_name
  storage_account_id                        = azurerm_storage_account.storeacc.id
  source                                    = "Microsoft.Storage"
}

# module "management_policy" {
#   source             = "./management_policy"
#   for_each           = try(var.storage_account.management_policies, {})
#   storage_account_id = azurerm_storage_account.storeacc.id
# }