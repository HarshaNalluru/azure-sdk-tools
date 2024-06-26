@maxLength(20)
@minLength(4)
@description('Used to generate names for all resources in this file')
param resourceBaseName string

@description('Required when create Azure Bot service')
param botAadAppClientId string

@secure()
@description('Required by Bot Framework package in your bot project')
param botAadAppClientSecret string

@secure()
param openAIApiKey string

@secure()
param azureOpenAIApiKey string

@secure()
param azureOpenAIEndpoint string

@secure()
param azureContentSafetyApiKey string

@secure()
param azureContentSafetyEndpoint string

param webAppSKU string

@maxLength(42)
param botDisplayName string

param serverfarmsName string = resourceBaseName
param webAppName string = resourceBaseName
param location string = resourceGroup().location

param azureEmbeddingModelDeploymentName string
param azureChatModelDeploymentName string

@secure()
param searchServiceUrl string
@secure()
param searchServiceApiKey string
@secure()
param githubToken string
@secure()
param appInsightConnectionString string



// Compute resources for your Web App
resource serverfarm 'Microsoft.Web/serverfarms@2021-02-01' = {
  kind: 'app'
  location: location
  name: serverfarmsName
  sku: {
    name: webAppSKU
  }
}

// Web App that hosts your bot
resource webApp 'Microsoft.Web/sites@2021-02-01' = {
  kind: 'app'
  location: location
  name: webAppName
  properties: {
    serverFarmId: serverfarm.id
    httpsOnly: true
    siteConfig: {
      alwaysOn: true
      appSettings: [
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1' // Run Azure APP Service from a package file
        }
        {
          name: 'RUNNING_ON_AZURE'
          value: '1'
        }
        {
          name: 'BOT_ID'
          value: botAadAppClientId
        }
        {
          name: 'BOT_PASSWORD'
          value: botAadAppClientSecret
        }
        {
          name: 'OpenAI__ApiKey'
          value: openAIApiKey
        }
        {
          name: 'Azure__OpenAIApiKey'
          value: azureOpenAIApiKey
        }
        {
          name: 'Azure__OpenAIEndpoint'
          value: azureOpenAIEndpoint
        }
        {
          name: 'Azure__ContentSafetyApiKey'
          value: azureContentSafetyApiKey
        }
        {
          name: 'Azure__ContentSafetyEndpoint'
          value: azureContentSafetyEndpoint
        }
        {
          name: 'Azure__EmbeddingModelDeploymentName'
          value: azureEmbeddingModelDeploymentName
        }
        {
          name: 'Azure__ChatModelDeploymentName'
          value: azureChatModelDeploymentName
        }
        {
          name: 'Search__SearchServiceUrl'
          value: searchServiceUrl
        }
        {
          name: 'Search__SearchServiceApiKey'
          value: searchServiceApiKey
        }
        {
          name: 'GITHUB_TOKEN'
          value: githubToken
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightConnectionString
        }
      ]
      ftpsState: 'FtpsOnly'
    }
  }
}

// Register your web service as a bot with the Bot Framework
module azureBotRegistration './botRegistration/azurebot.bicep' = {
  name: 'Azure-Bot-registration'
  params: {
    resourceBaseName: resourceBaseName
    botAadAppClientId: botAadAppClientId
    botAppDomain: webApp.properties.defaultHostName
    botDisplayName: botDisplayName
  }
}

// The output will be persisted in .env.{envName}. Visit https://aka.ms/teamsfx-actions/arm-deploy for more details.
output BOT_AZURE_APP_SERVICE_RESOURCE_ID string = webApp.id
output BOT_DOMAIN string = webApp.properties.defaultHostName
