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
var containerAppName = 'hello-world'

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

module containerApp 'modules/containerApp.bicep' = {
  name: 'app'
  params: {
    appInsightsName: appInsightsName
    containerAppEnvName: containerAppEnvName
    containerRegistryName: containerRegistryName
    cosmosDbAccountName: cosmosDb.outputs.cosmosDbName
    keyVaultName: keyVault.outputs.keyVaultName
    location: location
    tags: tags
  }
}

module helloWorld 'br/public:avm/res/app/container-app:0.2.0' = {
  name: 'helloWorldApp'
  params: {
    containers: [
      {
        image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
        name: containerAppName
        resources: {
          cpu: json('1.0')
          memory: '2Gi'
        }
      }
    ]
    environmentId: containerAppEnv.outputs.resourceId
    name: containerAppName
    tags: tags
    activeRevisionsMode: 'Multiple'
    location: location
    scaleMinReplicas: 0
    scaleMaxReplicas: 3
    scaleRules: [
      {
        name: 'http-rule'
        http: {
          metadata: {
            concurrentRequests: '100'
          }
        }
      }
    ]
    managedIdentities: {
      systemAssigned: true
    }
    exposedPort: 80
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

module containerAppEnv 'br/public:avm/res/app/managed-environment:0.4.4' = {
  name: containerAppEnvName
  params: {
    logAnalyticsWorkspaceResourceId: logAnalytics.id
    name: containerAppEnvName
    tags: tags
    logsDestination: 'log-analytics'
    zoneRedundant: false
  }
}
