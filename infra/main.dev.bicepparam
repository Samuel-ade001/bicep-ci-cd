using './main.bicep'

param location = 'eastus'
param environmentName = 'dev'
param workloadName = 'sampleapp'
param storageSku = 'Standard_LRS'
param publicNetworkAccess = 'Enabled'

param tags = {
  Application: 'Sample Application'
  Environment: 'Development'
  CostCenter: 'IT'
  Owner: 'Platform Team'
}
