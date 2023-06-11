vnet_name                                   = "poc-vnet"
resource_group_name                         = "poc-syn-ws-rg"
location                                    = "canadacentral"
business_unit                               = "DATA"
environment                                 = "DEV"
security_level                              = "COM"
subnet_name                                = "iaas-workloads"
synapse_subnet                              = "iaas-workloads"
address_space                               = ["10.2.0.0/24"]
pe_resource_group_name                      = "poc-vnet-rg"
subnets = {
  iaas-workloads = {
    cidrs                                   = ["10.2.0.0/24"]
    service_endpoints                       = ["Microsoft.Storage"]
    }
}
key_vault_name                              = "synapsekey"
dtlk_strg_account_name                      = "exampledc"
datalake_file_name                          = "testdc"
storage_account_name                        = "synapsemystoragedc"
storage_type                                = "blob"
enable_advanced_threat_protection           = true
containers_list = [
  { name = "mystore250", access_type = "private" },
  { name = "blobstore251", access_type = "blob" },
  { name = "containter252", access_type = "container" }
]
lifecycles = [
    {
      prefix_match                          = ["mystore250/folder_path"]
      tier_to_cool_after_days               = 0
      tier_to_archive_after_days            = 50
      delete_after_days                     = 100
      snapshot_delete_after_days            = 30
    },
    {
      prefix_match                          = ["blobstore251/another_path"]
      tier_to_cool_after_days               = 0
      tier_to_archive_after_days            = 30
      delete_after_days                     = 75
      snapshot_delete_after_days            = 30
    }
  ]
synapse_ws_name = "business-synapse-ws"
# Synapse SQL admin credentials
synadmin_username = "sqladminuser"
synadmin_password = "ThisIsNotVerySecure!"


tags = {
  //  Billing-Code   = "DA408503"
  billing_application                       = "Connected Data Platform (CDP)"
  billing_code                              = "ZYZ123"
  business_unit                             = "XYZ App Services"
  environment                               = "QA"
  solution_group                            = "DTS"
  solution_id                               = "XYZ-123"
  solution_ame                              = "Connected Data Platform"
}