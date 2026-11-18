targetScope = 'resourceGroup'

param location string = resourceGroup().location
param environmentName string = 'dev'
param workloadName string = 'sampleapp'

// -------------------------
// Variables
// -------------------------

var uniqueSuffix = uniqueString(resourceGroup().id)

var storageAccountName = take(
  toLower('${workloadName}${environmentName}${uniqueSuffix}'),
  24
)

var vnetName = 'vnet-${workloadName}-${environmentName}'
var nsgName = 'nsg-${workloadName}-${environmentName}'
var keyVaultName = take(
  'kv-${workloadName}-${environmentName}-${uniqueSuffix}',
  24
)

var logAnalyticsName = 'log-${workloadName}-${environmentName}'

// -------------------------
// Network Security Group
// -------------------------

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: nsgName
  location: location
}

// -------------------------
// Virtual Network
// -------------------------

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: vnetName
  location: location

  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }

    subnets: [
      {
        name: 'snet-app'
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
      {
        name: 'snet-data'
        properties: {
          addressPrefix: '10.0.2.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

// -------------------------
// Storage Account
// -------------------------

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-06-01' = {
  name: storageAccountName
  location: location

  sku: {
    name: 'Standard_LRS'
  }

  kind: 'StorageV2'

  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    defaultToOAuthAuthentication: true
  }
}

// -------------------------
// Blob Service
// -------------------------

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2025-06-01' = {
  parent: storageAccount
  name: 'default'
}

// -------------------------
// Blob Container
// -------------------------

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2025-06-01' = {
  parent: blobService
  name: 'deploymentfiles'

  properties: {
    publicAccess: 'None'
  }
}

// -------------------------
// Log Analytics Workspace
// -------------------------

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: logAnalyticsName
  location: location

  properties: {
    retentionInDays: 30
  }

  sku: {
    name: 'PerGB2018'
  }
}

// -------------------------
// Key Vault
// -------------------------

resource keyVault 'Microsoft.KeyVault/vaults@2024-11-01' = {
  name: keyVaultName
  location: location

  properties: {
    tenantId: tenant().tenantId

    sku: {
      family: 'A'
      name: 'standard'
    }

    enableRbacAuthorization: true
    enabledForDeployment: false
    enabledForTemplateDeployment: false
    publicNetworkAccess: 'Enabled'
  }
}

// -------------------------
// Outputs
// -------------------------

output storageAccountName string = storageAccount.name
output vnetName string = vnet.name
output nsgName string = nsg.name
output keyVaultName string = keyVault.name
output logAnalyticsWorkspaceName string = logAnalytics.name
