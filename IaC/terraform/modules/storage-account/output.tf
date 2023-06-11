output "storage_account_id" {
  description = "The ID of the storage account."
  value       = azurerm_storage_account.storeacc.id
}

output "storage_account" {
  description = "The name of the storage account."
  value       = azurerm_storage_account.storeacc.name
}

output "storage_account_primary_location" {
  description = "The primary location of the storage account"
  value       = azurerm_storage_account.storeacc.primary_location
}

output "storage_account_primary_web_endpoint" {
  description = "The endpoint URL for web storage in the primary location."
  value       = azurerm_storage_account.storeacc.primary_web_endpoint
}

output "storage_account_primary_web_host" {
  description = "The hostname with port if applicable for web storage in the primary location."
  value       = azurerm_storage_account.storeacc.primary_web_host
}

output "storage_primary_connection_string" {
  description = "The primary connection string for the storage account"
  value       = azurerm_storage_account.storeacc.primary_connection_string
  sensitive   = true
}

output "storage_primary_access_key" {
  description = "The primary access key for the storage account"
  value       = azurerm_storage_account.storeacc.primary_access_key
  sensitive   = true
}

output "storage_secondary_access_key" {
  description = "The primary access key for the storage account."
  value       = azurerm_storage_account.storeacc.secondary_access_key
  sensitive   = true
}
output "primary_blob_endpoint" {
  value       = azurerm_storage_account.storeacc.primary_blob_endpoint
  description = "The endpoint URL for blob storage in the primary location."
}

output "primary_blob_host" {
  value       = azurerm_storage_account.storeacc.primary_blob_host
  description = "The endpoint host for blob storage in the primary location."
}

output "secondary_blob_endpoint" {
  value       = azurerm_storage_account.storeacc.secondary_blob_endpoint
  description = "The endpoint URL for blob storage in the secondary location."
}

output "secondary_blob_host" {
  value       = azurerm_storage_account.storeacc.secondary_blob_host
  description = "The endpoint host for blob storage in the secondary location."
}

output "primary_file_endpoint" {
  value       = azurerm_storage_account.storeacc.primary_file_endpoint
  description = "The endpoint URL for file storage in the primary location."
}

output "secondary_file_endpoint" {
  value       = azurerm_storage_account.storeacc.secondary_file_endpoint
  description = "The endpoint URL for file storage in the secondary location."
}

output "primary_connection_string" {
  value       = azurerm_storage_account.storeacc.primary_connection_string
  sensitive   = true
  description = "The connection string associated with the primary location."
}

output "secondary_connection_string" {
  value       = azurerm_storage_account.storeacc.secondary_connection_string
  sensitive   = true
  description = "The connection string associated with the secondary location."
}

output "primary_blob_connection_string" {
  value       = azurerm_storage_account.storeacc.primary_blob_connection_string
  sensitive   = true
  description = "The connection string associated with the primary blob location."
}

output "secondary_blob_connection_string" {
  value       = azurerm_storage_account.storeacc.secondary_blob_connection_string
  sensitive   = true
  description = "The connection string associated with the secondary blob location."
}


