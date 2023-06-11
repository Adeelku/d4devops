#-------------------------------
# Local Declarations
#-------------------------------

locals {
  # resource_group_name      = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  # location                 = element(coalescelist(data.azurerm_resource_group.rgrp.*.location, azurerm_resource_group.rg.*.location, [""]), 0)
  private_endpoint_resources = merge(
    {
      dfs = true
    },
    {
      for resource in var.private_endpoint_resources_enabled :
        lower(resource) => true
    }
  )
  # Returns 'true' if the word 'any' exists in the IP rules list.
  is_any_acl_present = try(
    contains(var.storage_account_network_acls.ip_rules, "any"),
    false
  )
  storage_account_network_acls = [
    local.is_any_acl_present || var.storage_account_network_acls == null ? {
      bypass                     = ["AzureServices"],
      default_action             = "Allow",
      ip_rules                   = [],
      virtual_network_subnet_ids = []
    } : var.storage_account_network_acls
  ]
  storage_account_role_assignments_hash_map = {
    for assignment in var.storage_account_role_assignments :
    md5("${assignment.principal_id}${assignment.role_definition_name}") => assignment
  }
  data_lake_container_paths = {
    for path_object in var.data_lake_container_paths :
    md5("${path_object.container_name}${path_object.path_name}") => path_object
  }
}