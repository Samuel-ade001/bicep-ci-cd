targetScope = 'resourceGroup'

@description('Azure region where resources will be deployed.')
param location string = resourceGroup().location

@description('Environment name, such as dev, test, or prod.')
@allowed([
  'dev'
  'test'
  'prod'
])
param environmentName string

@description('Short application or workload name.')
@minLength(2)
@maxLength(12)
param workloadName string

@description('Storage account SKU.')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
])
param storageSku string = 'Standard_LRS'

@description('Whether public network access is enabled.')
param publicNetworkAccess string = 'Enabled'

@description('Common resource tags.')
param tags object = {}

var uniqueSuffix = uniqueString(
  subscription().subscriptionId,
  resourceGroup().id,
  workloadName,
  environmentName
)

var normalizedWorkloadName = toLower(replace(workloadName, '-', ''))

// Storage account names must:
// - Be globally unique
// - Use lowercase letters and numbers only
// - Be between 3 and 24 characters
var storageAccountName = take(
  '${normalizedWorkloadName}${environmentName}${uniqueSuffix}',
  24
)

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-06-01' = {
  name: storageAccountName
  location: location
  tags: union(tags, {
    Environment: environmentName
    Workload: workloadName
    ManagedBy: 'Bicep'
  })
  sku: {
    name: storageSku
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    defaultToOAuthAuthentication: true
    minimumTlsVersion: 'TLS1_2'
    publicNetworkAccess: publicNetworkAccess
    supportsHttpsTrafficOnly: true
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2025-06-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    deleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

resource deploymentContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2025-06-01' = {
  parent: blobService
  name: 'deploymentfiles'
  properties: {
    publicAccess: 'None'
  }
}

output storageAccountName string = storageAccount.name
output storageAccountId string = storageAccount.id
output blobContainerName string = deploymentContainer.name
output primaryBlobEndpoint string = storageAccount.properties.primaryEndpoints.blob
