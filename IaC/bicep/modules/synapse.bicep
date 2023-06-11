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

@description('Synapse Analytics name.')
param name string

@description('Key/Value pair of tags.')
param tags object = {}

@description('Synapse Analytics Managed Resource Group Name.')
param managedResourceGroupName string

// ADLS Gen 2
@description('Azure Data Lake Store Gen2 Resource Group Name.')
param adlsResourceGroupName string

@description('Azure Data Lake Store Gen2 Name.')
param adlsName string

@description('Azure Data Lake Store File System Name.')
param adlsFSName string

// Credentials
@description('Synapse Analytics Username.')
@secure()
param synapseUsername string

@description('Synapse Analytics Password.')
@secure()
param synapsePassword string

resource adls 'Microsoft.Storage/storageAccounts@2019-06-01' existing = {
  scope: resourceGroup(adlsResourceGroupName)
  name: adlsName
}

module dataLakeSynapseFS './storage-adlsgen2-fs.bicep' = {
  name: 'deploy-datalake-fs-for-synapse'
  scope: resourceGroup(adlsResourceGroupName)
  params: {
    adlsName: adlsName
    fsName: adlsFSName
  }
}

resource synapse 'Microsoft.Synapse/workspaces@2021-06-01' = {
  dependsOn: [
    dataLakeSynapseFS
  ]

  name: name
  tags: tags
  location: location
  properties: {
    trustedServiceBypassEnabled: true
    sqlAdministratorLoginPassword: synapsePassword
    managedResourceGroupName: managedResourceGroupName
    sqlAdministratorLogin: synapseUsername

    managedVirtualNetwork: 'default'
    managedVirtualNetworkSettings: {
      preventDataExfiltration: true
    }
    
    publicNetworkAccess: 'Enabled'

    defaultDataLakeStorage: {
      accountUrl: adls.properties.primaryEndpoints.dfs
      filesystem: adlsFSName
    }
  }
  identity: {
    type: 'SystemAssigned'
  }

  // Assign the workspace's system-assigned managed identity CONTROL permissions to SQL pools for pipeline integration
  resource synapse_msi_sql_control_settings 'managedIdentitySqlControlSettings@2021-05-01' = {
    name: 'default'
    properties: {
      grantSqlControlToManagedIdentity: {
        desiredState: 'Enabled'
      }
    }
  }

  resource synapse_audit 'auditingSettings@2021-05-01' = {
    name: 'default'
    properties: {
      isAzureMonitorTargetEnabled: true
      state: 'Enabled'
    }
  }

  resource synapse_securityAlertPolicies 'securityAlertPolicies@2021-05-01' = {
    name: 'Default'
    properties: {
      state: 'Enabled'
      emailAccountAdmins: false
    }
  }
}


// Grant Synapse access to ADLS Gen2 as Storage Blob Data Contributor
module roleAssignSynapseToADLSGen2 './storage-role-assignment-to-sp.bicep' = {
  name: 'rbac-${synapse.name}-${adls.name}'
  scope: resourceGroup(adlsResourceGroupName)
  params: {
    storageAccountName: adlsName
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe') // Storage Blob Data Contributor
    resourceSPObjectIds: array(synapse.identity.principalId)
  }
}

