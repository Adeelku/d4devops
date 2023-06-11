variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "create_resource_group" {
  description = "Whether to create resource group and use it for all networking resources"
  default     = false
}

variable "location" {
  type        = string
  description = "Location of the resource group"
}

variable "synapse_ws_name" {
  description = "Specifies the name of the synapse workspace."
  type        = string
}

variable "vnet_id" {
  type        = string
  description = "The ID of the vnet that should be linked to the DNS zone"
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet from which private IP addresses will be allocated for this Private Endpoint"
}

variable "adls_id" {
  type        = string
  description = "The ID of the adls associated with the syn workspace"
}

variable "key_vault_id" {
  type        = string
  description = "The ID of the key vault associated with the syn workspace"
}

variable "key_vault_name" {
  type        = string
  description = "The name of the key vault associated with the syn workspace"
}

variable "synadmin_username" {
  type        = string
  description = "The Login Name of the SQL administrator"
}

variable "synadmin_password" {
  type        = string
  description = "The Password associated with the sql_administrator_login for the SQL administrator"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}

variable "aad_login" {
  description = "AAD login"
  type = object({
    name      = string
    object_id = string
    tenant_id = string
  })
  default = {
    name      = "AzureAD Admin"
    object_id = "00000000-0000-0000-0000-000000000000"
    tenant_id = "00000000-0000-0000-0000-000000000000"
  }
}

variable private_endpoint_resources_enabled {
  type        = list(string)
  description = "Determines if private endpoint should be enabled for specific resources."

  default = ["datafactory", "keyvault", "blob"]

  validation {
    condition = length([
      for resource in var.private_endpoint_resources_enabled : true

      if lower(resource) == "datafactory" ||
         lower(resource) == "keyvault"    ||
         lower(resource) == "azuresynapse"

    ]) > 0 || length(var.private_endpoint_resources_enabled) == 0

    error_message = "Value must be one of ['datafactory', 'keyvault', 'blob', 'azuresynapse']."
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

variable "workspace_firewall" {
  type        = map(string)
  description = "The Name of the firewall rule."
  default     = {}
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
