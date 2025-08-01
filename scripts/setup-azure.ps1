# Azure Setup Script for Java Sample App (Free Tier) (PowerShell)
# This script helps set up Azure resources and configure GitHub secrets

param(
    [string]$SubscriptionId = "4cae711c-2969-439a-b455-19dd1a5693eb",
    [string]$ResourceGroupName = "rg-java-sample-app",
    [string]$Location = "Canada Central",
    [string]$AppServiceName = "app-java-sample"
)

# Colors for output
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"

Write-Host "Azure Setup Script for Java Sample App (Free Tier)" -ForegroundColor $Green
Write-Host "==============================================" -ForegroundColor $Green

# Check if Azure CLI is installed
try {
    $azVersion = az version --output json | ConvertFrom-Json
    Write-Host "Azure CLI version: $($azVersion.'azure-cli')" -ForegroundColor $Green
} catch {
    Write-Host "Azure CLI is not installed. Please install it first." -ForegroundColor $Red
    Write-Host "Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli" -ForegroundColor $Red
    exit 1
}

# Check if logged in to Azure
try {
    $account = az account show --output json | ConvertFrom-Json
    Write-Host "Logged in as: $($account.user.name)" -ForegroundColor $Green
} catch {
    Write-Host "Please log in to Azure..." -ForegroundColor $Yellow
    az login
}

# Set subscription
Write-Host "Setting subscription to: $SubscriptionId" -ForegroundColor $Green
az account set --subscription $SubscriptionId

# Create resource group
Write-Host "Creating resource group: $ResourceGroupName" -ForegroundColor $Green
az group create --name $ResourceGroupName --location $Location

# Deploy infrastructure using Bicep
Write-Host "Deploying infrastructure using Bicep (Free Tier)..." -ForegroundColor $Green
az deployment group create `
    --resource-group $ResourceGroupName `
    --template-file infrastructure/main.bicep `
    --parameters resourceGroupName=$ResourceGroupName `
    --parameters appServiceName=$AppServiceName `
    --parameters location=$Location `
    --parameters appServicePlanSku="F1"

# Get App Service details
Write-Host "Getting App Service details..." -ForegroundColor $Green
$appServiceUrl = az webapp show --name $AppServiceName --resource-group $ResourceGroupName --query defaultHostName -o tsv
Write-Host "App Service URL: https://$appServiceUrl" -ForegroundColor $Green

# Get publish profile
Write-Host "Getting publish profile..." -ForegroundColor $Green
az webapp deployment list-publishing-profiles `
    --name $AppServiceName `
    --resource-group $ResourceGroupName `
    --xml > publish-profile.xml

Write-Host "Publish profile saved to publish-profile.xml" -ForegroundColor $Green

# Create service principal for GitHub Actions
Write-Host "Creating service principal for GitHub Actions..." -ForegroundColor $Green
$spName = "github-actions-java-sample"
$spOutput = az ad sp create-for-rbac --name $spName --role contributor --scopes "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName" --sdk-auth

Write-Host "Service principal created successfully!" -ForegroundColor $Green

# Parse the service principal output to extract individual values
$spJson = $spOutput | ConvertFrom-Json
$clientId = $spJson.clientId
$tenantId = $spJson.tenantId
$clientSecret = $spJson.clientSecret

# Display next steps
Write-Host "=============================================" -ForegroundColor $Yellow
Write-Host "NEXT STEPS:" -ForegroundColor $Yellow
Write-Host "=============================================" -ForegroundColor $Yellow
Write-Host ""
Write-Host "1. Add the following secrets to your GitHub repository:" -ForegroundColor $Green
Write-Host "   Go to: Settings → Secrets and variables → Actions"
Write-Host ""
Write-Host "2. Required GitHub Secrets:" -ForegroundColor $Green
Write-Host "   AZURE_CLIENT_ID: $clientId"
Write-Host ""
Write-Host "   AZURE_TENANT_ID: $tenantId"
Write-Host ""
Write-Host "   AZURE_CLIENT_SECRET: $clientSecret"
Write-Host ""
Write-Host "   AZURE_SUBSCRIPTION_ID: $SubscriptionId"
Write-Host ""
Write-Host "   AZURE_WEBAPP_NAME: $AppServiceName"
Write-Host ""
Write-Host "   AZURE_WEBAPP_PUBLISH_PROFILE:"
Write-Host "   (Copy the content from publish-profile.xml)"
Write-Host ""
Write-Host "3. Run the infrastructure deployment workflow:" -ForegroundColor $Green
Write-Host "   Go to: Actions → Deploy Azure Infrastructure → Run workflow"
Write-Host ""
Write-Host "4. After infrastructure is deployed, push code to trigger the build and deploy workflow" -ForegroundColor $Green
Write-Host ""
Write-Host "5. Your app will be available at: https://$appServiceUrl" -ForegroundColor $Green
Write-Host ""
Write-Host "6. Cost Information:" -ForegroundColor $Green
Write-Host "   - App Service Plan (F1): FREE"
Write-Host "   - Application Insights: FREE (up to 5GB/month)"
Write-Host "   - Total cost: `$0/month"
Write-Host ""
Write-Host "7. Region: Canada Central" -ForegroundColor $Green
Write-Host ""
Write-Host "=============================================" -ForegroundColor $Yellow 