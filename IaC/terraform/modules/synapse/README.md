# Azure Synapse Workspace Module

This terraform module creates a Synapse Workspace in Azure.

## Assumptions
* An Azure virtual network, subnets, and security groups exist

# Examples
## Synapse Workspace with private endpoint
`terraform apply`

main.tf:
```
# Azure Provider configuration
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

# Use existing subnet where private endpoint is to be created
data "azurerm_subnet" "subnet" {
  name                                                = "iaas-workloads"
  virtual_network_name                                = "pevnet"
  resource_group_name                                 = "NETWORKING-RG"
}

module "synapse_workspace" {
    source                                            = "../../modules/analytics/synapse"
    resource_group_name                               = module.workloads_resource_group.name
    location                                          = module.workloads_resource_group.location
    synapse_ws_name                                   = "business-synapse-ws"
    vnet_id                                           = "synapsevnet"
    subnet_id                                         = data.azurerm_subnet.subnet.id
    adls_id                                           = module.data_lake.id
    key_vault_id                                      = module.key-vault.id
    key_vault_name                                    = module.key-vault.name
    synadmin_username                                 = "sqladminuser"
    synadmin_password                                 = "ThisIsNotVerySecure!"

    aad_login = {
        name                                          = "azureuser@contoso.com"
        object_id                                     = data.azurerm_client_config.current.object_id
        tenant_id                                     = data.azurerm_client_config.current.tenant_id
  }
  workspace_firewall = {
    name                                              = "AllowAll"
    start_ip                                          = "0.0.0.0"
    end_ip                                            = "255.255.255.255"
  } 
  private_endpoint_resources_enabled                  = []
  private_endpoint_name                               = "privatelink.azuresynapse.net"
  pe_resource_group_name                              = data.azurerm_subnet.subnet.resource_group_name
  pe_network = {
    resource_group_name                               = data.azurerm_subnet.subnet.resource_group_name
    vnet_name                                         = data.azurerm_subnet.subnet.virtual_network_name
    subnet_name                                       = data.azurerm_subnet.subnet.name
  }
  tags = {
    ProjectName                                       = "demo-internal"
    Env                                               = "dev"
    Owner                                             = "user@example.com"
    BusinessUnit                                      = "CORP"
    ServiceClass = "Gold"
  }
}
```

# Resources Created
This modules creates:
* 1 Synapse Workspace
* 2 Synapse Workspace Private endpoint (private_endpoint_resources_enabled = [])
* 3 Key Vault Secret stored in keyvault for password rotation support
* 4 Azurerm Synapse Firewall Rule
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
| location | Location in which Synapse Workspace will be deployed | `string` | n/a | yes |
| resource\_group\_name | Name of resource group into which Synapse Workspace will be deployed | `string` | n/a | yes |
| create\_resource\_group | Whether to create resource group and use it for all networking resources | `bool` | `false` | yes
| synapse\_ws\_name | Specifies the name of the synapse workspace | `string` | n/a | yes |
| key\_vault\_id | The ID of the keyVault where the customer owned encryption key is present | `string` | n/a | yes |
| key\_vault\_name | The name of the key vault associated with the syn workspace | `string` | n/a | yes |
| adls\_id | The ID of the adls associated with the syn workspace | `string` | n/a | yes |
| synadmin\_username | Specifies The login name of the SQL administrator | `string` | n/a | yes |
| synadmin\_password | he Password associated with the sql_administrator_login for the SQL administrator | `string` | n/a | yes |
| aad\_login | AAD login | `object` | n/a | no |
| private\_endpoint\_resources\_enabled | Determines if private endpoint should be enabled for specific resources | `list(string)` | n/a | yes |
| pe\_network | Private endpoint network configuration | `object` | n/a | yes (if private endpoint resource is enabled) |
| vnet\_id | The ID of the vnet that should be linked to the DNS zone | `string` | n/a | yes (if private endpoint resource is enabled) |
| subnet\_id | The ID of the subnet from which private IP addresses will be allocated for this Private Endpoint | `string` | n/a | yes (if private endpoint resource is enabled) |
| pe\_resource\_group\_name | Private endpoint Resource Group Name | `string` | n/a | yes (if private endpoint resource is enabled) |
| private\_endpoint\_name | Private endpoint name | `string` | n/a | yes (if private endpoint resource is enabled) |
| workspace\_firewall | The Name of the firewall rule | `map(string)` | `{}` | no
| tags | A map of the tags to use on the resources that are deployed with this module | `map(string)` | `{}` | yes |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Synapse Workspace |
| connectivity_endpoints | A list of Connectivity endpoints for this Synapse Workspace |
| managed_resource_group_name | Workspace managed resource group |
| identity | An identity block which contains the Managed Service Identity information for this Synapse Workspace |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


# References
This repo is based on:
* [terraform standard module structure](https://www.terraform.io/docs/modules/index.html#standard-module-structure)

## Reference documents:
* Azure Synapse: https://docs.microsoft.com/en-us/azure/synapse-analytics/
* Azure Synapse Terraform Docs: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_workspace
* Azure Security Group Terraform Docs: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group
* Azure Subnet Terraform Docs: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
