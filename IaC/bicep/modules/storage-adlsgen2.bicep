// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('Location for the deployment.')
param location string = resourceGroup().location

@description('ADLS Gen2 Storage Account Name')
param name string

@description('Key/Value pair of tags.')
param tags object = {}

@description('Default Network Acls.  Default: deny')
param defaultNetworkAcls string = 'deny'

@description('Bypass Network Acls.  Default: AzureServices,Logging,Metrics')
param bypassNetworkAcls string = 'AzureServices,Logging,Metrics'

@description('Array of Subnet Resource Ids for Virtual Network Access')
param subnetIdForVnetAccess array = []

/* Storage Account */
resource storage 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  tags: tags
  location: location
  name: name
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'StorageV2'
  sku: {
    name: 'Standard_GRS'
  }
  properties: {
    accessTier: 'Hot'
    isHnsEnabled: true
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    encryption: {
      requireInfrastructureEncryption: true
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
        queue: {
          enabled: true
          keyType: 'Account'
        }
        table: {
          enabled: true
          keyType: 'Account'
        }
      }
    }
    networkAcls: {
      defaultAction: defaultNetworkAcls
      bypass: bypassNetworkAcls
      virtualNetworkRules: [for subnetId in subnetIdForVnetAccess: {
        id: subnetId
        action: 'Allow'
      }]
    }
  }
}

resource threatProtection 'Microsoft.Security/advancedThreatProtectionSettings@2019-01-01' = {
  name: 'current'
  scope: storage
  properties: {
    isEnabled: true
  }
}

// Outputs
output storageName string = storage.name
output storageId string = storage.id
