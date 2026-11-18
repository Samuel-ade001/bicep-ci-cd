using './main.bicep'

param location = 'eastus2'
param environmentName = 'prod'
param workloadName = 'sampleapp'
param storageSku = 'Standard_ZRS'
param publicNetworkAccess = 'Enabled'

param tags = {
  Application: 'Sample Application'
  Environment: 'Production'
  CostCenter: 'IT'
  Owner: 'Platform Team'
}
