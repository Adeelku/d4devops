variable "create_resource_group" {
  description = "Whether to create resource group and use it for all networking resources"
  default     = false
}

variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
  default     = ""
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  default     = ""
}

variable "key_vault_name" {
  description = "The Name of the key vault"
  default     = ""
}

variable "key_vault_sku_pricing_tier" {
  description = "The name of the SKU used for the Key Vault. The options are: `standard`, `premium`."
  default     = "standard"
}

variable "enabled_for_deployment" {
  description = "Allow Virtual Machines to retrieve certificates stored as secrets from the key vault."
  default     = true
}

variable "enabled_for_disk_encryption" {
  description = "Allow Disk Encryption to retrieve secrets from the vault and unwrap keys."
  default     = true
}

variable "enabled_for_template_deployment" {
  description = "Allow Resource Manager to retrieve secrets from the key vault."
  default     = true
}

variable "enable_rbac_authorization" {
  description = "Specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions"
  default     = false
}

variable "enable_purge_protection" {
  description = "Is Purge Protection enabled for this Key Vault?"
  default     = false
}

variable "soft_delete_retention_days" {
  description = "The number of days that items should be retained for once soft-deleted. The valid value can be between 7 and 90 days"
  default     = 90
}

variable "access_policies" {
  description = "List of access policies for the Key Vault."
  default     = []
}

variable "network_acls" {
  description = "Network rules to apply to key vault."
  type = object({
    bypass                     = string
    default_action             = string
    ip_rules                   = list(string)
    virtual_network_subnet_ids = list(string)
  })
  default = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}

variable private_endpoint_resources_enabled {
  type        = list(string)
  description = "Determines if private endpoint should be enabled for specific resources."

  default = ["datafactory", "keyvault", "blob"]

  validation {
    condition = length([
      for resource in var.private_endpoint_resources_enabled : true

      if lower(resource) == "datafactory" ||
         lower(resource) == "keyvault"

    ]) > 0 || length(var.private_endpoint_resources_enabled) == 0

    error_message = "Value must be one of ['datafactory', 'keyvault']."
  }
}

variable pe_network {
    type = object({
      resource_group_name = string
      vnet_name           = string
      subnet_name         = string
    })
   default = {
     resource_group_name = null
     subnet_name = null
     vnet_name = null
   }
}

variable "pe_resource_group_name" {
  type        = string
  description = "Private endpoint Resource Group Name."
  default = null
}

variable  "private_endpoint_name"  {
  type        = string
  description = "Private endpoint name."
  default = null
}
