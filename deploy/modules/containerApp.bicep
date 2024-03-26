@description('The name of the Container App Environment')
param containerAppEnvName string

@description('The location to deploy all my resources')
param location string

@description('The name of the Container Registry')
param containerRegistryName string

@description('The tags to apply to this resource')
param tags object

@description('The name of the Key Vault')
param keyVaultName string

@description('The name of the Application Insights workspace')
param appInsightsName string

@description('The name of the Cosmos DB account that will be deployed')
param cosmosDbAccountName string

var containerAppName = 'hello-world'
var acrPullRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')

resource env 'Microsoft.App/managedEnvironments@2023-11-02-preview' existing = {
  name: containerAppEnvName
}

resource acr 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = {
  name:containerRegistryName
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing =  {
  name: keyVaultName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
}

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2024-02-15-preview' existing = {
  name: cosmosDbAccountName
}

resource containerApp 'Microsoft.App/containerApps@2023-08-01-preview' = {
  name: containerAppName
  tags: tags
  location: location
  properties: {
    managedEnvironmentId: env.id
    configuration: {
      ingress: {
        external: true
        targetPort: 80
        allowInsecure: false
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      }
      registries: [
        {
          server: acr.properties.loginServer
          username: acr.listCredentials().username
          identity: 'system'
        }
      ]
      secrets: [
        {
          name: 'cosmos-db-connection-string'
          value: cosmosDbAccount.listConnectionStrings().connectionStrings[0].connectionString
        }
        {
          name: 'cosmos-db-endpoint'
          keyVaultUrl: 'https://${keyVault.name}.vault.azure.net/secrets/CosmosDbEndpoint'
          identity: 'system'
        }
      ]
      activeRevisionsMode: 'Multiple'
    }
    template: {
      containers: [
        {
          name: containerAppName
          image: 'mcr.microsoft.com/k8se/quickstart:latest'
          env: [
            {
              name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
              value: appInsights.properties.InstrumentationKey
            }
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              value: appInsights.properties.ConnectionString
            }
            {
              name: 'COSMOS_DB_CONNECTION_STRING'
              secretRef: 'cosmos-db-connection-string'
            }
            {
              name: 'COSMOS-DB-ENDPOINT'
              secretRef: 'cosmos-db-endpoint'
            }
          ]
          resources: {
            cpu: json('1.0')
            memory: '2Gi'
          }
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 3
        rules: [
          {
            name: 'http-rule'
            http: {
              metadata: {
                concurrentRequests: '100'
              }
            }
          }
        ]
      }
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource accessPolicies 'Microsoft.KeyVault/vaults/accessPolicies@2023-07-01' = {
  name: 'add'
  parent: keyVault
  properties: {
    accessPolicies: [
      {
        objectId: containerApp.identity.principalId
        tenantId: containerApp.identity.tenantId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      }
    ] 
  }
}

resource acrPullRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acr.id, containerApp.id, acrPullRoleId)
  scope: acr
  properties: {
    principalId: containerApp.identity.principalId
    roleDefinitionId: acrPullRoleId
    principalType: 'ServicePrincipal'
  }
}
