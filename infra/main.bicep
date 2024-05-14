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

@description('The name of the Key Vault')
param keyVaultName string

var tags = {
  environment: 'production'
  owner: 'Will Velida'
  application: 'lets-build-aca'
}

module logAnalytics 'core/monitor/log-analytics.bicep' = {
  name: 'law'
  params: {
    location: location 
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    tags: tags
  }
}

module keyVault 'core/security/key-vault.bicep' = {
  name: 'kv'
  params: {
    keyVaultName: keyVaultName
    location: location
    tags: tags
  }
}

module appInsights 'core/monitor/app-insights.bicep' = {
  name: 'appins'
  params: {
    appInsightsName: appInsightsName
    keyVaultName: keyVault.outputs.name
    location: location
    logAnalyticsName: logAnalytics.outputs.name
    tags: tags
  }
}

module containerRegistry 'core/host/container-registry.bicep' = {
  name: 'acr'
  params: {
    containerRegistryName: containerRegistryName
    location: location
    tags: tags
  }
}

module env 'core/host/container-app-env.bicep' = {
  name: 'env'
  params: {
    appInsightsName: appInsights.outputs.name
    containerAppEnvironmentName: containerAppEnvName
    location: location
    logAnalyticsName: logAnalytics.outputs.name
    tags: tags
  }
}

module frontend 'apps/frontend-ui/frontend-ui.bicep' = {
  name: 'ui'
  params: {
    containerAppEnvName: env.outputs.containerAppEnvName
    location: location
    tags: tags
  }
}

module backend 'apps/backend-api/backend-api.bicep' = {
  name: 'backend'
  params: {
    containerAppEnvName: env.outputs.containerAppEnvName
    location: location
    tags: tags
  }
}
