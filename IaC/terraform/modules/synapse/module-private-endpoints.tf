#---------------------------------------------------------
# Synapse Workspace Private endpoint
#----------------------------------------------------------

data "azurerm_subscription" "current" {
}
module "subscription" {
  source          = "../../../modules/subscription-data"
  subscription_id = data.azurerm_subscription.current.subscription_id
}

module private_endpoint {
  count                           = local.private_endpoint_resources["SqlSyn"] ? 1 : 0
  source                          = "../../networking/private-endpoint"
  pe_resource_group_name          = var.pe_resource_group_name      # Resource Group where the new Private Endpoint will be created. 
  private_endpoint_name           = var.private_endpoint_name
  subresource_names               = ["Sql"]
  endpoint_resource_id            = azurerm_synapse_workspace.syn_ws.id
  location                        = var.location
  tags                            = var.tags

  pe_network = var.pe_network  
  dns = {
    zone_ids   = ["/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.pe_resource_group_name}/providers/Microsoft.Network/privateDnsZones/privatelink.sql.azuresynapse.net"]
    zone_name  = "privatelink.sql.azuresynapse.net"
  }
} 
