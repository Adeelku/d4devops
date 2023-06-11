# Azure Storage Account

This terraform module creates Storage Account in Azure.

## Assumptions
* An Azure virtual network, subnets, and security groups exist

# Examples
## Blob Storage Account with private endpoint
`terraform apply`

main.tf:
```
# Azure Provider configuration
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

# Use existing subnet where PE is to be created
data "azurerm_subnet" "subnet" {
  name                                            = "iaas-workloads"
  virtual_network_name                            = "datavnet"
  resource_group_name                             = "DATA-DEV-RG"
}

module "storage" {
  source                                          = "../../modules/storage-account"
 

  # By default, this module will not create a resource group
  # proivde a name to use an existing resource group, specify the existing resource group name, 
  # and set the argument to `create_resource_group = false`. Location will be same as existing RG.

  storage_account                                 = "mystorageacct"
  create_resource_group                           = false
  resource_group_name                             = "DATA-DEV-RG"
  location                                        = "canadacentral"
  environment_type                                = "dev"
  security_level                                  = "sec"
  business_unit                                   = "data"
  storage_type                                    = "blob"

  # To enable advanced threat protection set argument to `true`

  enable_advanced_threat_protection               = true
  min_tls_versionallow_blob_public_access         = "TLS1_2"

  # Container lists with access_type to create

  containers_list = [
    { name = "mystore250", access_type = "private" },
    { name = "blobstore251", access_type = "blob" },
    { name = "containter252", access_type = "container" }
  ]

  # Lifecycle management for storage account.
  # Must specify the value to each argument and default is `0` 
  lifecycles = [
    {
      prefix_match                                = ["mystore250/folder_path"]
      tier_to_cool_after_days                     = 0
      tier_to_archive_after_days                  = 50
      delete_after_days                           = 100
      snapshot_delete_after_days                  = 30
    },
    {
      prefix_match                                = ["blobstore251/another_path"]
      tier_to_cool_after_days                     = 0
      tier_to_archive_after_days                  = 30
      delete_after_days                           = 75
      snapshot_delete_after_days                  = 30
    }
  ]
  encryption_scope_name = "microsoftmanaged"
  private_endpoint_resources_enabled              = []
  private_endpoint_name                           = var.private_endpoint_name
  pe_resource_group_name                          = data.azurerm_subnet.subnet.resource_group_name
  pe_network = {
    resource_group_name                           = data.azurerm_subnet.subnet.resource_group_name
    vnet_name                                     = data.azurerm_subnet.subnet.virtual_network_name
    subnet_name                                   = data.azurerm_subnet.subnet.name
  }
  tags = {
    ProjectName                                   = "demo-internal"
    Env                                           = "dev"
    Owner                                         = "user@example.com"
    BusinessUnit                                  = "CORP"
    ServiceClass = "Gold"
  }
}
```

# Resources Created
This modules creates:
* 1 Azure Storage Account
* 2 Azurerm Storage Encryption Scope
* 3 Azure Storage Account Private endpoint (private_endpoint_resources_enabled = [])
* 4 Resource Group Creation or selection - Default is "false"

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |
| azurerm | >= 2.60.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 2.60.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| location | Location in whichStorage Account will be deployed | `string` | n/a | yes |
| resource\_group\_name | Name of resource group into which Storage Account instance will be deployed | `string` | n/a | yes |
| create\_resource\_group | Whether to create resource group and use it for all networking resources | `bool` | `false` | yes
| storage\_account | The name of the storage account | `string` | n/a | yes |
| account\_kind | The type of storage account. Valid options are `BlobStorage`, `BlockBlobStorage`, `FileStorage`, `Storage` and `StorageV2` | `string` | `StorageV2` | no |
| skuname | The SKUs supported by Microsoft Azure Storage. Valid options are `Premium_LRS`, `Premium_ZRS`, `Standard_GRS`, `Standard_GZRS`, `Standard_LRS`, `Standard_RAGRS`, `Standard_RAGZRS`, `Standard_ZRS` | `string` | `Standard_RAGRS` | no |
| access\_tier | The storage account access tier. Valid options are Hot and Cool | `string` | `Hot` | no |
| min\_tls\_version | The minimum supported TLS version for the storage account | `string` | `TLS1_2` | no |
| nfsv3\_enabled | Is NFSv3 protocol enabled? Changing this forces a new resource to be created |  `bool` | `false` | no |
| enable\_large\_file\_share | Enable Large File Share | `bool` | `false` | no |
| blob\_soft\_delete\_retention\_days | Specifies the number of days that the blob should be retained, between `1` and `365` days. Defaults to `7` | `string` | `7` | no |
| container\_soft\_delete\_retention\_days | Specifies the number of days that the blob should be retained, between `1` and `365` days. Defaults to `7` |  `string` | `7` | no |
| enable\_versioning | Is versioning enabled? Default to `false` | `bool` | `false` | no |
| enable\_advanced\_threat\_protection | Boolean flag which controls if advanced threat protection is enabled | `bool` | `false` | no |
| enable\_https\_traffic\_only | Forces HTTPS if enabled | `bool` | `true` | no |
| shared\_access\_key\_enabled | Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key | `bool` | `false` | no |
| blob\_versioning\_enabled | Controls whether blob object versioning is enabled | `bool` | `false` | no |
| containers\_list | List of containers to create and their access levels | `list(objects)` | `[]` | no |
| encryption\_scope\_name | The name which should be used for this Storage Encryption Scope | `string` | n/a | yes |
| file\_shares | List of containers to create and their access levels | `list(objects)` | `[]` | no |
| lifecycles | Configure Azure Storage firewalls and virtual networks | `list(objects)` | `[]` | no |
| identity\_ids | Specifies a list of user managed identity ids to be assigned. This is required when `type` is set to `UserAssigned` or `SystemAssigned, UserAssigned` | `string` | `SystemAssigned` | no |
| business\_unit | Business Unit or Department e.g. Cloud Eng. | `string` | n/a | yes |
| environment\_type | Environmnet type e.g. DEV, QA, PROD | `string` | n/a | yes |
| security\_level | Storage Account security level e.g. COM, SEC | `string` | n/a | yes |
| storage\_type | Storage Account type e.g. blob, file | `string` | n/a | yes |
| private\_endpoint\_resources\_enabled | Determines if private endpoint should be enabled for specific resources | `map(string)` | `{}` | yes |
| pe\_network | Private endpoint network configuration | `object` | n/a | yes (if private endpoint resource is enabled) |
| pe\_resource\_group\_name | Private endpoint Resource Group Name | `string` | n/a | yes (if private endpoint resource is enabled) |
| private\_endpoint\_name | Private endpoint name | `string` | n/a | yes (if private endpoint resource is enabled) |
| tags | A map of the tags to use on the resources that are deployed with this module | `map(string)` | `{}` | yes |

## Outputs

| Name | Description |
|------|-------------|
| storage_account_id | The ID of the Azure Storage Account |
| storage_account | The name of the Azure Storage Account |
| storage_account_primary_location | The primary location of the storage account |
| storage_account_primary_web_endpoint | The endpoint URL for web storage in the primary location |
| storage_account_primary_web_host | The hostname with port if applicable for web storage in the primary location | 
| storage_primary_connection_string | The primary connection string for the storage account |
| storage_primary_access_key | The primary access key for the storage account | 
| primary_blob_endpoint | The endpoint URL for blob storage in the primary location | 
| primary_blob_host | The endpoint host for blob storage in the primary location |
| secondary_blob_endpoint | The endpoint URL for blob storage in the secondary location |
| secondary_blob_host | The endpoint host for blob storage in the secondary location |
| primary_file_endpoint | The endpoint URL for file storage in the primary location |
| secondary_file_endpoint | The endpoint URL for file storage in the secondary location |
| primary_connection_string | The connection string associated with the primary location | 
| secondary_connection_string | The connection string associated with the secondary location |
| primary_blob_connection_string | The connection string associated with the primary blob location |
| secondary_blob_connection_string | The connection string associated with the secondary blob location |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


# References
This repo is based on:
* [terraform standard module structure](https://www.terraform.io/docs/modules/index.html#standard-module-structure)

## Reference documents:
* Azure Storage Account: https://docs.microsoft.com/en-us/azure/?product=storage
* Azure Storage Account Terraform Docs: https://registry.terraform.io/providers/hashicorp/azurerm/2.62.1/docs/resources/storage_encryption_scope
* Azure Security Group Terraform Docs: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group
* Azure Subnet Terraform Docs: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
