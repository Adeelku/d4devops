# Azure - Resource Group Module

## Introduction

This module will create a new Resource Group in Azure.

<!--- BEGIN_TF_DOCS --->
## Providers

| Name | Version |
|------|---------|
| azurerm | >= 2.0.0 |
| random | >= 2.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| location | Azure Region | `string` | n/a | yes |
| name | Name to be applied to resources (inclusive) | <pre>object({<br>    company_code         = string<br>    business_unit           = string<br>    environment_type             = string<br>  })</pre> | `null` | no |
| tags | A map of the tags to use on the resources that are deployed with this module | `map(string)` | n/a | yes |
| unique\_name | Freeform input to append to resource group name. Set to 'true', to append 5 random integers | `string` | n/a | yes |
| business\_unit | Business Unit or Department e.g. Cloud Eng. | `string` | n/a | yes |
| environment\_type | Environmnet type e.g. DEV, QA, PROD | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| id | Resource group id |
| location | Resource group location |
| name | Resource group name |
| rg | Resource group resource |
<!--- END_TF_DOCS --->