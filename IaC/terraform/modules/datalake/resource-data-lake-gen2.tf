#---------------------------------------------------------
# Data Lookups
#----------------------------------------------------------

data "azurerm_client_config" "current" {}

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

#---------------------------------------
# Azure Storage Account Deployment
#---------------------------------------

resource "azurerm_storage_account" "adlsacct" {
  location                  = var.location
  resource_group_name       = var.resource_group_name
  tags                      = var.tags
  name                      = var.storage_account_name
  access_tier               = var.storage_account_access_tier
  account_replication_type  = var.storage_account_replication_type
  account_tier              = var.storage_account_tier
  account_kind              = var.storage_account_kind
  is_hns_enabled            = var.storage_account_hns_enabled
  min_tls_version           = var.storage_account_min_tls_version
  enable_https_traffic_only = true

  dynamic "network_rules" {
    for_each = local.storage_account_network_acls
    iterator = acl
    content {
      bypass                     = acl.value.bypass
      default_action             = acl.value.default_action
      ip_rules                   = acl.value.ip_rules
      virtual_network_subnet_ids = acl.value.virtual_network_subnet_ids
    }
  }
}

#---------------------------------------------------
# Azure Storage Data Lake Gen 2 Filesystem Creation
#---------------------------------------------------

resource "azurerm_storage_data_lake_gen2_filesystem" "gen2" {
  name               = var.dtlk_file_name
  storage_account_id = azurerm_storage_account.adlsacct.id
  properties = {
    for key, value in try(var.properties) : key => base64encode(value)
  }
}

resource "azurerm_storage_data_lake_gen2_path" "adlsacct" {
  for_each           = local.data_lake_container_paths
  storage_account_id = azurerm_storage_account.adlsacct.id
  path               = each.value.path_name
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.gen2.name
  resource           = try(each.value.resource_type, "directory")
}

#---------------------------------------
# Azure Role Assignment
#---------------------------------------
resource "azurerm_role_assignment" "roles" {
  for_each             = local.storage_account_role_assignments_hash_map
  scope                = azurerm_storage_account.adlsacct.id
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
}  