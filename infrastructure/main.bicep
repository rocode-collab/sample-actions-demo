@description('The name of the resource group')
param resourceGroupName string

@description('The name of the App Service Plan')
param appServicePlanName string = 'asp-java-sample'

@description('The name of the App Service')
param appServiceName string = 'app-java-sample'

@description('The location for all resources')
param location string = resourceGroup().location

@description('The SKU for the App Service Plan (F1 for free tier)')
param appServicePlanSku string = 'F1'

@description('The Java version to use')
param javaVersion string = '17'

@description('Tags to apply to all resources')
param tags object = {}

// App Service Plan (Free Tier)
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSku
    tier: 'Free'
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
  tags: tags
}

// App Service
resource appService 'Microsoft.Web/sites@2023-01-01' = {
  name: appServiceName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'JAVA|${javaVersion}-java17'
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'JAVA_OPTS'
          value: '-Xmx512m -Xms256m'
        }
        {
          name: 'SPRING_PROFILES_ACTIVE'
          value: 'prod'
        }
      ]
    }
  }
  tags: tags
}

// Application Insights (Free tier)
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'ai-${appServiceName}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: ''
  }
  tags: tags
}

// Outputs
output appServiceName string = appService.name
output appServiceUrl string = 'https://${appService.properties.defaultHostName}'
output appServicePlanName string = appServicePlan.name
output appInsightsName string = appInsights.name
output appInsightsKey string = appInsights.properties.InstrumentationKey 