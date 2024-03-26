@description('The name of the Key Vault')
param keyVaultName string

@description('The location to deploy all my resources')
param location string

@description('The tags to apply to this resource')
param tags object

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    enabledForTemplateDeployment: true
    accessPolicies: [
      
    ]
  }
}

output keyVaultName string = keyVault.name
