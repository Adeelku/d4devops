# Azure Key Vault Terraform Module

Azure Key Vault is a tool for securely storing and accessing secrets. A secret is anything that you want to tightly control access to, such as API keys, passwords, or certificates. A vault is a logical group of secrets.

This Terraform Module creates a Key Vault also adds required access policies for azure AD users, groups and azure AD service principals. This also enables private endpoint and sends all logs to log analytic workspace or storage.

## Resources Supported

* [Acess Polices for AD users, groups and SPN](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy)
* [Secrets](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret)
* [Certifiate Contacts](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault#contact)
* [Private Endpoints](https://www.terraform.io/docs/providers/azurerm/r/private_endpoint.html)
* [Private DNS zone for `privatelink` A records](https://www.terraform.io/docs/providers/azurerm/r/private_dns_zone.html)
* [Azure Log Dignostics](https://www.terraform.io/docs/providers/azurerm/r/network_security_group.html)

## Assumptions
* An Azure virtual network, subnets, and security groups exist

# Examples
## Azure Key Vault with azurerm monitor private link scope and service
`terraform apply`

main.tf:
```
# Azure Provider configuration
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {
}

module "key-vault" {
  source                                        = "../../modules/security/keyvault"

  # By default, this module will not create a resource group and expect to provide 
  # a existing RG name to use an existing resource group. Location will be same as existing RG. 
  # set the argument to `create_resource_group = true` to create new resrouce.
  location                                      = "canadacentral"
  resource_group_name                           = "SECURITY-DEV-RG"
  key_vault_name                                = "demo-project-kv"
  key_vault_sku_pricing_tier                    = "premium"

  # Once `Purge Protection` has been Enabled it's not possible to Disable it
  # Deleting the Key Vault with `Purge Protection` enabled will schedule the Key Vault to be deleted
  # The default retention period is 90 days, possible values are from 7 to 90 days
  # use `soft_delete_retention_days` to set the retention period

  enable_purge_protection                       = false

  # Creating Private Endpoint requires, VNet name and address prefix to create a subnet
  # private_endpoint_resources_enabled flag will create a `privatelink.vaultcore.azure.net` private endpoint. 

  private_endpoint_resources_enabled            = []
  pe_network = {
    resource_group_name                         = "NETWORK-DEV-RG"
    vnet_name                                   = "pevnet"
    subnet_name                                 = "iaas-workloads"
  }
  private_endpoint_name                         = "privatelink.vaultcore.azure.net"
  pe_resource_group_name                        = "NETWORK-DEV-RG"
  # Adding TAG's to your Azure resources
  tags = {
    ProjectName                                 = "demo-internal"
    Env                                         = "dev"
    Owner                                       = "user@example.com"
    BusinessUnit                                = "CORP"
    ServiceClass = "Gold"
  }
}
```

# Resources Created
This modules creates:
* 1 Azure Key Vault
* 2 Azure Key Vault Private Endpoint
* 3 Resource Group Creation or selection - Default is "false"


## Key Vault Advanced features

### `enabled_for_deployment`

To use Key Vault with Azure Resource Manager virtual machines, the `enabled_for_deployment` property on Key Vault must be set to `true`. This access is enabled by default for this module. Incase you want to disable it set the argument `enabled_for_deployment = "false"`.

### `enabled_for_disk_encryption`

We can configure Azure Disk Encryption to use Azure Key Vault to control and manage disk encryption keys and secrets. This access is enabled by default for this module. Incase you want to disable it set the argument `enabled_for_disk_encryption = "false"`.

> Warning: The key vault and VMs must be in the same subscription. Also, to ensure that encryption secrets don't cross regional boundaries, Azure Disk Encryption requires the Key Vault and the VMs to be co-located in the same region. Create and use a Key Vault that is in the same subscription and region as the VMs to be encrypted.

### `enabled_for_template_deployment`

When you need to pass a secure value (like a password) as a parameter during deployment, you can retrieve the value from an Azure Key Vault. To access the Key Vault when deploying Managed Applications, you must grant access to the Appliance Resource Provider service principal. This access is enabled by default for this module. Incase you want to disable it set the argument `enabled_for_template_deployment = "false"`.

### Soft-Delete and Purge Protection

Soft-delete is enabled by default. When enabled, resources marked as deleted resources are retained for a specified period (90 days by default). The service further provides a mechanism for recovering the deleted object, essentially undoing the deletion.

Purge protection is an optional Key Vault behavior and is not enabled by default. Purge protection can only be enabled once soft-delete is enabled. It can be turned on using this module by setting the argument `enable_purge_protection = true`.

When purge protection is on, a vault or an object in the deleted state cannot be purged until the retention period has passed. Soft-deleted vaults and objects can still be recovered, ensuring that the retention policy will be followed. Soft delete retention can be updated using  `soft_delete_retention_days` argument with a valid days.

> The default retention period is 90 days for the soft-delete and the purge protection retention policy uses the same interval. Once set, the retention policy interval cannot be changed.

## Configure Azure Key Vault firewalls and virtual networks

Configure Azure Key Vault firewalls and virtual networks to restrict access to the key vault. The virtual network service endpoints for Key Vault (Microsoft.KeyVault) allow you to restrict access to a specified virtual network and set of IPv4 address ranges.

Default action is set to `Allow` when no network rules matched. A `virtual_network_subnet_ids` or `ip_rules` can be added to `network_acls` block to allow request that is not Azure Services.


## Private Endpoint - Integrate Key Vault with Azure Private Link

Azure Private Endpoint is a network interface that connects you privately and securely to a service powered by Azure Private Link. Private Endpoint uses a private IP address from your VNet, effectively bringing the service into your VNet.

With Private Link, Microsoft offering the ability to associate a logical server to a specific private IP address (also known as private endpoint) within the VNet. Clients can connect to the Private endpoint from the same VNet, peered VNet in same region, or via VNet-to-VNet connection across regions. Additionally, clients can connect from on-premises using ExpressRoute, private peering, or VPN tunneling.

## Recommended naming and tagging conventions

Applying tags to your Azure resources, resource groups, and subscriptions to logically organize them into a taxonomy. Each tag consists of a name and a value pair. For example, you can apply the name `Environment` and the value `Production` to all the resources in production.
For recommendations on how to implement a tagging strategy, see Resource naming and tagging decision guide.

## Requirements

Name | Version
-----|--------
terraform | >= 0.13
azurerm | >= 2.59.0

## Providers

| Name | Version |
|------|---------|
azurerm | >= 2.59.0
random | >= 3.1.0
azuread | >= 2.7.0


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| location | Location in which Key Vault will be deployed | `string` | n/a | yes |
| resource\_group\_name | Name of resource group into which Key Vault will be deployed | `string` | n/a | yes |
| create\_resource\_group | Whether to create resource group and use it for all networking resources | `bool` | `false` | yes
| key\_vault\_name| The name of the key vault | `string` | n/a | yes |
| key\_vault\_sku\_pricing\_tier | The name of the SKU used for the Key Vault. The options are: `standard`, `premium` | `string` | `standard` | yes |
| enabled\_for\_deployment | Allow Virtual Machines to retrieve certificates stored as secrets from the Key Vault | `string` | `false` | no |
| enabled\_for\_disk\_encryption | Allow Disk Encryption to retrieve secrets from the vault and unwrap keys | `string` | `false` | no |
| enabled\_for\_template\_deployment | Allow Resource Manager to retrieve secrets from the Key Vault | `string` | `false` | no |
| enable\_rbac\_authorization | Specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions | `string` | `false` | no |
| enable\_purge\_protection | Is Purge Protection enabled for this Key Vault? | `string` | `false` | no |
| soft\_delete\_retention\_days | The number of days that items should be retained for once soft-deleted. The valid value can be between 7 and 90 days | `string` | `90` | no |
| access\_policies | List of access policies for the Key Vault | `list`|`{}` | no |
| network\_acls | Network rules to apply to key vault | `object`|`{}` | no |
| private\_endpoint\_resources\_enabled | Determines if private endpoint should be enabled for specific resources | `list(string)` | n/a | yes |
| pe\_network | Private endpoint network configuration | `object` | n/a | yes (if private endpoint resource is enabled) |
| pe\_resource\_group\_name | Private endpoint Resource Group Name | `string` | n/a | yes (if private endpoint resource is enabled) |
| private\_endpoint\_name | Private endpoint name | `string` | n/a | yes (if private endpoint resource is enabled) |
| tags | A map of the tags to use on the resources that are deployed with this module | `map(string)` | `{}` | yes |


## Outputs

Name | Description
---- | -----------
`id`|The ID of the Key Vault
`name`|Name of key vault created
`vault_uri`|The URI of the Key Vault, used for performing operations on keys and secrets


## Other resources

* [Azure Key Vault documentation (Azure Documentation)](https://docs.microsoft.com/en-us/azure/key-vault/)
* [Terraform AzureRM Provider Documentation](https://www.terraform.io/docs/providers/azurerm/index.html)