// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'subscription'

@description('Location for the deployment.')
param location string = deployment().location

// Tags
@description('A set of key/value pairs of tags assigned to the resource group and resources.')
param resourceTags object

// Resource Groups
@description('Resource groups required for the achetype.  It includes automation, compute, monitor, networking, networkWatcher, security and storage.')
param resourceGroups object

// Synapse
@description('Synapse Analytics configuration.  Includes username.')
param synapse object

var synapsePassword = '${uniqueString(rgCompute.id)}*${toUpper(uniqueString(synapse.username))}'

var datalakeStorageName = 'datalake${uniqueString(rgStorage.id)}'
var synapseName = '${synapse.name}-syn${uniqueString(rgCompute.id)}'


resource rgStorage 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroups.storage
  location: location
  tags: resourceTags
}

resource rgCompute 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroups.compute
  location: location
  tags: resourceTags
}



module dataLake './modules/storage-adlsgen2.bicep' = {
  name: 'deploy-datalake'
  scope: rgStorage
  params: {
    tags: resourceTags
    name: datalakeStorageName
    location: location

    defaultNetworkAcls: 'Deny'
    subnetIdForVnetAccess: []
  }
}


module synapseAnalytics './modules/synapse.bicep' = {
  name: 'deploy-synapse'
  scope: rgCompute
  params: {
    name: synapseName
    tags: resourceTags
    location: location 

    managedResourceGroupName: '${rgCompute.name}-${synapseName}-${uniqueString(rgCompute.id)}'

    adlsResourceGroupName: rgStorage.name
    adlsName: dataLake.outputs.storageName
    adlsFSName: 'synapsecontainer'

    synapseUsername: synapse.username 
    synapsePassword: synapsePassword

  }
}
