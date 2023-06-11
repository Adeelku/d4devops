output "storage_account_id" {
  value       = azurerm_storage_account.adlsacct.id
  description = "The ID of the Azure Storage Account."
}

output "storage_account_name" {
  value       = azurerm_storage_account.adlsacct.name
  description = "The name of the Azure Storage Account."
}

output "storage_account_dfs_endpoint" {
  value = {
    primary   = azurerm_storage_account.adlsacct.primary_dfs_endpoint
    secondary = azurerm_storage_account.adlsacct.primary_dfs_endpoint
  }
  description = "The primary and secondary Data Lake storage endpoints."
}

output "storage_account_access_tier" {
  value       = azurerm_storage_account.adlsacct.access_tier
  description = "The storage account access tier."
}

output "storage_account_kind" {
  value       = azurerm_storage_account.adlsacct.account_kind
  description = "The storage account kind."
}

output "storage_account_account_tier" {
  value       = azurerm_storage_account.adlsacct.account_tier
  description = "The storage account tire."
}

output "storage_account_replication_type" {
  value       = azurerm_storage_account.adlsacct.account_replication_type
  description = "The storage account replication type."
}

output "data_lake_containers" {
  value       = try(azurerm_storage_data_lake_gen2_filesystem.gen2, {})
  description = "A map of Azure Data Lake Gen 2 filesystem containers."
}

output "data_lake_paths" {
  value       = try(azurerm_storage_data_lake_gen2_path.adlsacct, {})
  description = "A map of Azure Data Lake Gen 2 filesystem paths."
}

#---------------------------------------
# SENSITIVE OUTPUTS
#---------------------------------------
output "storage_account_access_key" {
  value = {
    primary   = azurerm_storage_account.adlsacct.primary_access_key
    secondary = azurerm_storage_account.adlsacct.secondary_access_key
  }
  description = "The storage account primary and secondary access keys."
  sensitive   = true
}

output "storage_account_connection_string" {
  value = {
    primary   = azurerm_storage_account.adlsacct.primary_connection_string
    secondary = azurerm_storage_account.adlsacct.secondary_connection_string
  }
  description = "The storage account primary and secondary connection strings."
  sensitive   = true
}

output "id" {
  description = "The ID of the Data Lake Gen2 File System."
  value       = azurerm_storage_data_lake_gen2_filesystem.gen2.id
}