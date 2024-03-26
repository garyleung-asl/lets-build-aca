@description('The name of the Cosmos DB account that will be deployed')
param cosmosDbAccountName string

@description('The location to deploy all my resources')
param location string

@description('The tags to apply to this resource')
param tags object

@description('The name of the key vault that this Cosmos DB resource will store secrets in')
param keyVaultName string

var databaseName = 'todoDB'
var cosmosConnectionStringSecretName = 'CosmosDbConnectionString'
var cosmosDbEndpointSecretName = 'CosmosDbEndpoint'
var cosmosPrimaryMasterKeySecretName = 'CosmosDbPrimaryMasterKey'

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2024-02-15-preview' = {
  name: cosmosDbAccountName
  location: location
  tags: tags
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
      }
    ]
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    enableFreeTier: true
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-02-15-preview' = {
  name: databaseName
  parent: cosmosDbAccount
  properties: {
    resource: {
      id: databaseName
    }
    options: {
      throughput: 1000
    }
  }
}

resource cosmosDbConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: cosmosConnectionStringSecretName
  parent: keyVault
  properties: {
    value: cosmosDbAccount.listConnectionStrings().connectionStrings[0].connectionString
  }
}

resource cosmosDbEndpointSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: cosmosDbEndpointSecretName
  parent: keyVault
  properties: {
    value: cosmosDbAccount.properties.documentEndpoint
  }
}

resource cosmosDbPrimaryMasterKeySecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: cosmosPrimaryMasterKeySecretName
  parent: keyVault
  properties: {
    value: cosmosDbAccount.listKeys().primaryMasterKey
  }
}
