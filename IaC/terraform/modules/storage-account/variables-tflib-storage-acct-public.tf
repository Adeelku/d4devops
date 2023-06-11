variable "create_resource_group" {
  description = "Whether to create resource group and use it for all networking resources"
  default     = false
}

variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  default     = "canadacentral"
}

variable "storage_account" {
  description = "The name of the azure storage account"
}

variable "account_kind" {
  description = "The type of storage account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2."
  default     = "StorageV2"
}

variable "skuname" {
  description = "The SKUs supported by Microsoft Azure Storage. Valid options are Premium_LRS, Premium_ZRS, Standard_GRS, Standard_GZRS, Standard_LRS, Standard_RAGRS, Standard_RAGZRS, Standard_ZRS"
  default     = "Standard_RAGRS"
}

variable "access_tier" {
  description = "Defines the access tier for BlobStorage and StorageV2 accounts. Valid options are Hot and Cool."
  default     = "Hot"
}

variable "min_tls_version" {
  description = "The minimum supported TLS version for the storage account"
  default     = "TLS1_2"
}

variable "nfsv3_enabled" {
  description = "Is NFSv3 protocol enabled? Changing this forces a new resource to be created"
  type        = bool
  default     = false
}

variable "enable_large_file_share" {
  description = "Enable Large File Share."
  type        = bool
  default     = false
}

variable "blob_soft_delete_retention_days" {
  description = "Specifies the number of days that the blob should be retained, between `1` and `365` days. Defaults to `7`"
  default     = 7
}

variable "container_soft_delete_retention_days" {
  description = "Specifies the number of days that the blob should be retained, between `1` and `365` days. Defaults to `7`"
  default     = 7
}

variable "enable_versioning" {
  description = "Is versioning enabled? Default to `false`"
  default     = false
}

variable "enable_advanced_threat_protection" {
  description = "Boolean flag which controls if advanced threat protection is enabled."
  default     = false
}

variable "enable_https_traffic_only" {
  description = "Forces HTTPS if enabled."
  type        = bool
  default     = true
}

variable "shared_access_key_enabled" {
  description = "Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key"
  type        = bool
  default     = false
}

variable "blob_versioning_enabled" {
  description = "Controls whether blob object versioning is enabled."
  type        = bool
  default     = false
}


variable "containers_list" {
  description = "List of containers to create and their access levels."
  type        = list(object({ name = string, access_type = string }))
  default     = []
}


variable encryption_scope_name {
  description = " (Required)The name which should be used for this Storage Encryption Scope"
  type = string
}

variable "file_shares" {
  description = "List of containers to create and their access levels."
  type        = list(object({ name = string, quota = number }))
  default     = []
}

variable "lifecycles" {
  description = "Configure Azure Storage firewalls and virtual networks"
  type        = list(object({ prefix_match = set(string), tier_to_cool_after_days = number, tier_to_archive_after_days = number, delete_after_days = number, snapshot_delete_after_days = number }))
  default     = []
}

variable "identity_ids" {
  description = "Specifies a list of user managed identity ids to be assigned. This is required when `type` is set to `UserAssigned` or `SystemAssigned, UserAssigned`"
  default     = null
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
         lower(resource) == "keyvault"    ||
         lower(resource) == "blob"

    ]) > 0 || length(var.private_endpoint_resources_enabled) == 0

    error_message = "Value must be one of ['datafactory', 'keyvault', 'blob']."
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

variable "business_unit" {
  description = "Business Unit or Department e.g. DTP"
  type        = string
}

variable "environment_type" {
  description = "Environmnet type e.g. DEV, QA, PROD"
  type        = string
}

variable security_level {
  description = "Storage Account security level e.g. COM, SEC"
  type        = string
}

variable storage_type {
  description = "Storage Account type e.g. blob, file"
  type        = string
}


