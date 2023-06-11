output "id" {
  description = "The ID of the Storage Account Management Policy."
  value       = azurerm_storage_management_policy.mgmt_policy.id
}

output "storage_account_id" {
  description = "The ID of the Storage Account Management Policy was applied to."
  value       = azurerm_storage_management_policy.mgmt_policy.storage_account_id
}