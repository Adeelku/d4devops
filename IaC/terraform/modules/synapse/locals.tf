#-------------------------------
# Local Declarations
#-------------------------------
locals {
  # resource_group_name      = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  # location                 = element(coalescelist(data.azurerm_resource_group.rgrp.*.location, azurerm_resource_group.rg.*.location, [""]), 0)
  private_endpoint_resources = merge(
    {
      SqlSyn       = true
    },
    {
      for resource in var.private_endpoint_resources_enabled :
        lower(resource) => true
    }
  )
} 