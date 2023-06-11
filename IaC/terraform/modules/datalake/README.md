# Azure Data Lake Module

This terraform module creates Data Lake instance in Azure.

## Assumptions
* An Azure virtual network, subnets, and security groups exist

# Examples
## Data Lake instance with private endpoint
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
  name                                          = "iaas-workloads"
  virtual_network_name                          = "datavnet"
  resource_group_name                           = "DATA-DEV-RG"
}

module "data_lake" {
  source                                        = "../../../modules/datalake"
  location                                      = "canadacentral"
  resource_group_name                           = "DATALAKE-DEV-RG"
  storage_account_name                          = "testdtlk"
  tags = {
      ProjectName                               = "demo-internal"
      Env                                       = "dev"
      Owner                                     = "user@example.com"
      BusinessUnit                              = "CORP"
      ServiceClass = "Gold"
    }
  dtlk_file_name                                = "test1"
  properties = {
    dap                                         = "200-basic-ml"
  }

  data_lake_container_paths = [
    { container_name = "test1", path_name = "con01" },
  ]
  storage_account_role_assignments = [
    { principal_id = data.azurerm_client_config.current.object_id, role_definition_name = "Owner" }
  ]

  storage_account_network_acls = {
    bypass                                      = ["AzureServices"]
    default_action                              = "Deny"
    ip_rules                                    = ["any"]
    virtual_network_subnet_ids                  = []
  }

  private_endpoint_resources_enabled            = []
  private_endpoint_name                         = "privatelink.dfs.core.windows.net"
  pe_resource_group_name                        = data.azurerm_subnet.subnet.resource_group_name
  pe_network = {
    resource_group_name                         = data.azurerm_subnet.subnet.resource_group_name
    vnet_name                                   = data.azurerm_subnet.subnet.virtual_network_name
    subnet_name                                 = data.azurerm_subnet.subnet.name
  }
}
```

# Resources Created
This modules creates:
* 1 Azure Storage Account
* 2 Azure Storage Data Lake Gen 2 Filesystem
* 3 Azure Storage Data Lake Gen 2 Filesystem Private endpoint (private_endpoint_resources_enabled = [])
* 4 Azure Role Assignment
* 5 Resource Group Creation or selection - Default is "false"

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
| location | Location in which Data Lake instance will be deployed | `string` | n/a | yes |
| resource\_group\_name | Name of resource group into which Data Lake instance will be deployed | `string` | n/a | yes |
| create\_resource\_group | Whether to create resource group and use it for all networking resources | `bool` | `false` | yes
| storage\_account\_name | The name of the storage account | `string` | n/a | yes |
| dtlk\_file\_name | The name of the Data Lake Gen2 File System which should be created within the Storage Account | `string` | n/a | yes |
| storage\_account\_access\_tier | The storage account access tier | `string` | `Hot` | no |
| storage\_account\_replication\_type | The storage account replication type | `string` | `RAGRS` | no |
| storage\_account\_tier | The storage account tier | `string` | `Standard` | no |
| storage\_account\_kind | The storage account type | `string` | `StorageV2` | no |
| storage\_account\_hns\_enabled | Enable or disable hierarchical namespace. This is required for Azure Data Lake Storage Gen 2 | `bool` | `true` | no |
| storage\_account\_min\_tls\_version | The minimum TLS version this Storage Account supports | `string` | `TLS1_2` | no |
| storage\_account\_network\_acls | Requires a custom object with attributes 'bypass', 'default_action', 'ip_rules', 'virtual_network_subnet_ids | `object` | `null` | no |
| storage\_account\_role\_assignments | A list of objects that define role assignments for the storage account | `list(objects)` | `[]` | no |
| data\_lake\_container\_paths | Data Lake filesystem paths | `list(objects)` | `[]` | no |
| properties | A mapping of Key to Base64-Encoded Values which should be assigned to this Data Lake Gen2 File System | `list(objects)` | `[]` | no |
| private\_endpoint\_resources\_enabled | Determines if private endpoint should be enabled for specific resources | `map(string)` | `{}` | yes |
| pe\_network | Private endpoint network configuration | `object` | n/a | yes (if private endpoint resource is enabled) |
| pe\_resource\_group\_name | Private endpoint Resource Group Name | `string` | n/a | yes (if private endpoint resource is enabled) |
| private\_endpoint\_name | Private endpoint name | `string` | n/a | yes (if private endpoint resource is enabled) |
| tags | A map of the tags to use on the resources that are deployed with this module | `map(string)` | `{}` | yes |

## Outputs

| Name | Description |
|------|-------------|
| storage_account_id | The ID of the Azure Storage Account |
| storage_account_name | The name of the Azure Storage Account |
| storage_account_dfs_endpoint | The primary and secondary Data Lake storage endpoints |
| id | The ID of the Data Lake Gen2 File System |
| storage_account_access_tier | The storage account access tier |
| storage_account_kind | The storage account kind |
| storage_account_account_tier | The storage account tire |
| storage_account_replication_type | The storage account replication type |
| data_lake_containers | A map of Azure Data Lake Gen 2 filesystem containers |
| data_lake_paths | A map of Azure Data Lake Gen 2 filesystem paths |
| storage_account_access_key | The storage account primary and secondary access keys (sensitive) |
| storage_account_connection_string | The storage account primary and secondary connection strings (sensitive) |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


# References
This repo is based on:
* [terraform standard module structure](https://www.terraform.io/docs/modules/index.html#standard-module-structure)

## Reference documents:
* Azure Data Factory: https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-introduction
* Azure Data Factory Terraform Docs: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_data_lake_gen2_filesystem
* Azure Security Group Terraform Docs: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group
* Azure Subnet Terraform Docs: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
