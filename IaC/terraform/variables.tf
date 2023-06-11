variable "location" {
  type        = string
  description = "Location of the resource group and modules"
}

variable resource_group_name {
  type = string
  description = "synapse workspace resource group"

}

variable "synapse_ws_name" {
  description = "Specifies the name of the synapse workspace."
  type        = string
}

# Mandatory tags
variable "business_unit" {
  description = "customer.businessUnit"
  type        = string
}

variable "environment" {
  description = "customer.environment"
  type        = string
}

resource "random_string" "postfix" {
  length  = 6
  special = false
  upper   = false
}

variable "address_space" {
  description = "CIDRs for virtual network"
  type        = list(string)
}

variable "subnets" {
  description = "Map of subnets. Keys are subnet names, Allowed values are the same as for subnet_defaults"
  type        = any
  default     = {}

  validation {
    condition = (length(compact([for subnet in var.subnets : (!lookup(subnet, "configure_nsg_rules", true) &&
      (contains(keys(subnet), "allow_internet_outbound") ||
        contains(keys(subnet), "allow_lb_inbound") ||
        contains(keys(subnet), "allow_vnet_inbound") ||
      contains(keys(subnet), "allow_vnet_outbound")) ?
    "invalid" : "")])) == 0)
    error_message = "Subnet rules not allowed when configure_nsg_rules is set to \"false\"."
  }
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

variable "synadmin_username" {
  type        = string
  description = "The Login Name of the SQL administrator"
  default     = "sqladminuser"
}

variable "synadmin_password" {
  type        = string
  description = "The Password associated with the sql_administrator_login for the SQL administrator"
  default     = "ThisIsNotVerySecure!"
}

variable "enable_syn_sqlpool" {
  description = "Variable to enable or disable Synapse Dedicated SQL pool deployment"
  default     = false
}

variable "enable_syn_sparkpool" {
  description = "Variable to enable or disable Synapse Spark pool deployment"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "A map of additional tags to add to the tags output"
  default     = {}
}

variable "key_vault_name" {
  type = string
  description = "Synapse workspace keyvault name"
}

variable "dtlk_strg_account_name" {
  type = string
  description = "Datalake Storage account name"
}

variable "storage_account_name" {
  type = string
  description = "Storage account name"
}

variable "pe_resource_group_name" {
  description = "The name of the resource group. Changing this forces a new resource to be created."
  default     = null
}

variable "security_level" {}

variable "storage_type" {}

variable enable_advanced_threat_protection {}
variable containers_list {}
variable lifecycles {}
variable vnet_name {}
variable subnet_name{}
variable synapse_subnet{}
variable datalake_file_name {}


