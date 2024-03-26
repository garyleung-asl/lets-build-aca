@description('The location to deploy all my resources')
param location string = resourceGroup().location

@description('The name of the log analytics workspace')
param logAnalyticsWorkspaceName string

@description('The name of the Application Insights workspace')
param appInsightsName string

@description('The name of the Container App Environment')
param containerAppEnvName string

@description('The name of the Container Registry')
param containerRegistryName string

@description('The name of the Cosmos DB account that will be deployed')
param cosmosDbAccountName string

@description('The name of the Key Vault')
param keyVaultName string

var tags = {
  environment: 'production'
  owner: 'Will Velida'
  application: 'lets-build-aca'
}

module keyVault 'modules/keyVault.bicep' = {
  name: 'kv'
  params: {
    keyVaultName: keyVaultName
    location: location
    tags: tags
  }
}

module cosmosDb 'modules/cosmosDb.bicep' = {
  name: 'cosmos'
  params: {
    cosmosDbAccountName: cosmosDbAccountName
    keyVaultName: keyVaultName
    location: location
    tags: tags
  }
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsWorkspaceName
  tags: tags
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource appInsights 'microsoft.insights/components@2020-02-02' = {
  name: appInsightsName
  tags: tags
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource acr 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: containerRegistryName
  tags: tags
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource env 'Microsoft.App/managedEnvironments@2023-08-01-preview' = {
  name: containerAppEnvName
  tags: tags
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
  }
}
