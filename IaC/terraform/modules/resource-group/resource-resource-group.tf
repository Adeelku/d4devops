resource "random_integer" "suffix" {
  count = var.unique_name == "true" ? 1 : 0

  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "rg" {
  #name     = local.unique_name != null ? "${local.resource_group_name}-${local.unique_name}" : local.resource_group_name
  name                      = upper(join("-", [local.company_code,var.business_unit,var.environment_type,"RG"]))
  location = var.location
  tags     = var.tags
}