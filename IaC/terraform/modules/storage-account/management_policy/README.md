# Azure Storage Account Management Policy

This terraform module creates Storage Account Management Policy in Azure.

## Assumptions
* An Azure virtual network, subnets, and security groups exist

# Resources Created
This modules creates:
* 1 Azure Storage Account Management Policy

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
| storage\_account\_id | Specifies the id of the storage account to apply the management policy to | `string` | n/a | yes |
| rules | A rule block as documented below. Supports the following parameters: `name`, `enabled`, `filters`, `actions` | `object` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Storage Account Management Policy |
| storage_account_id | The ID of the Storage Account Management Policy was applied to |


<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


# References
This repo is based on:
* [terraform standard module structure](https://www.terraform.io/docs/modules/index.html#standard-module-structure)

## Reference documents:
* Azure Storage Account Management Policy: https://docs.microsoft.com/en-us/azure/storage/blobs/lifecycle-management-policy-configure?tabs=azure-portal
* Azure Storage Account Management Policy Terraform Docs: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_management_policy

