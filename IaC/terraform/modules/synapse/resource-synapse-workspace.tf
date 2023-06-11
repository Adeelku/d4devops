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

#---------------------------------------------------------
# Azure Synapse Workspace creation or selection 
#----------------------------------------------------------

resource "azurerm_synapse_workspace" "syn_ws" {
  name                                    = lower(var.synapse_ws_name)
  # resource_group_name                   = local.resource_group_name
  # location                              = local.location
  resource_group_name                     = var.resource_group_name
  location                                = var.location
  storage_data_lake_gen2_filesystem_id    = var.adls_id
  sql_administrator_login                 = var.synadmin_username
  sql_administrator_login_password        = var.synadmin_password
  tags                                     = var.tags
  identity {
    type = "SystemAssigned"
  }
  aad_admin = [
    {
      login                               = "AzureAD Admin"
      object_id                           = data.azurerm_client_config.current.object_id
      tenant_id                           = data.azurerm_client_config.current.tenant_id
    }
  ]

}

resource "random_password" "sql_admin" {
  count = try(var.synadmin_password, null) == null ? 1 : 0

  length           = 128
  special          = true
  upper            = true
  number           = true
  override_special = "$#%"
}

#---------------------------------------------------------------------------
# Store the generated password into keyvault for password rotation support
#---------------------------------------------------------------------------
resource "azurerm_key_vault_secret" "sql_admin_password" {
  count = try(var.synadmin_password, null) == null ? 1 : 0
  name         = format("%s-synapse-sql-admin-password", azurerm_synapse_workspace.syn_ws.name)
  value        = random_password.sql_admin.0.result
  key_vault_id = var.key_vault_id

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "azurerm_key_vault_secret" "sql_admin" {
  count = try(var.synadmin_password, null) == null ? 1 : 0

  name         = format("%s-synapse-sql-admin-username", azurerm_synapse_workspace.syn_ws.name)
  value        = var.synadmin_username
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "synapse_name" {
  count = try(var.synadmin_password, null) == null ? 1 : 0

  name         = format("%s-synapse-name", azurerm_synapse_workspace.syn_ws.name)
  value        = azurerm_synapse_workspace.syn_ws.name
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "synapse_rg_name" {
  count = try(var.synadmin_password, null) == null ? 1 : 0

  name         = format("%s-synapse-resource-group-name", azurerm_synapse_workspace.syn_ws.name)
  value        = var.resource_group_name
  key_vault_id = var.key_vault_id
}


#---------------------------------------------------------------------------
# Configure Synapse Workspace Firewall Rule
#---------------------------------------------------------------------------
resource "azurerm_synapse_firewall_rule" "wrkspc_firewall" {
  count = try(var.workspace_firewall, null) == null ? 0 : 1

  name                 = var.workspace_firewall.name
  synapse_workspace_id = azurerm_synapse_workspace.syn_ws.id
  start_ip_address     = var.workspace_firewall.start_ip
  end_ip_address       = var.workspace_firewall.end_ip
}