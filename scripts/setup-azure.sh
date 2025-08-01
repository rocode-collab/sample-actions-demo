#!/bin/bash

# Azure Setup Script for Java Sample App (Free Tier)
# This script helps set up Azure resources and configure GitHub secrets

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Azure Setup Script for Java Sample App (Free Tier)${NC}"
echo "=============================================="

# Configuration
SUBSCRIPTION_ID="4cae711c-2969-439a-b455-19dd1a5693eb"
RESOURCE_GROUP_NAME="rg-java-sample-app"
LOCATION="canadacentral"
APP_SERVICE_NAME="app-java-sample"

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}Azure CLI is not installed. Please install it first.${NC}"
    echo "Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if logged in to Azure
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}Please log in to Azure...${NC}"
    az login
fi

# Set subscription
echo -e "${GREEN}Setting subscription to: ${SUBSCRIPTION_ID}${NC}"
az account set --subscription $SUBSCRIPTION_ID

# Create resource group
echo -e "${GREEN}Creating resource group: ${RESOURCE_GROUP_NAME}${NC}"
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# Deploy infrastructure using Bicep
echo -e "${GREEN}Deploying infrastructure using Bicep (Free Tier)...${NC}"
az deployment group create \
    --resource-group $RESOURCE_GROUP_NAME \
    --template-file infrastructure/main.bicep \
    --parameters appServiceName=$APP_SERVICE_NAME \
    --parameters location=$LOCATION \
    --parameters appServicePlanSku="F1"

# Get App Service details
echo -e "${GREEN}Getting App Service details...${NC}"
APP_SERVICE_URL=$(az webapp show --name $APP_SERVICE_NAME --resource-group $RESOURCE_GROUP_NAME --query defaultHostName -o tsv)
echo "App Service URL: https://$APP_SERVICE_URL"

# Get publish profile
echo -e "${GREEN}Getting publish profile...${NC}"
az webapp deployment list-publishing-profiles \
    --name $APP_SERVICE_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --xml > publish-profile.xml

echo -e "${GREEN}Publish profile saved to publish-profile.xml${NC}"

# Create service principal for GitHub Actions
echo -e "${GREEN}Creating service principal for GitHub Actions...${NC}"
SP_NAME="github-actions-java-sample"
SP_OUTPUT=$(az ad sp create-for-rbac --name $SP_NAME --role contributor --scopes /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME --sdk-auth)

echo -e "${GREEN}Service principal created successfully!${NC}"

# Parse the service principal output to extract individual values
CLIENT_ID=$(echo $SP_OUTPUT | jq -r '.clientId')
TENANT_ID=$(echo $SP_OUTPUT | jq -r '.tenantId')
CLIENT_SECRET=$(echo $SP_OUTPUT | jq -r '.clientSecret')

# Display next steps
echo -e "${YELLOW}=============================================${NC}"
echo -e "${YELLOW}NEXT STEPS:${NC}"
echo -e "${YELLOW}=============================================${NC}"
echo ""
echo -e "${GREEN}1. Add the following secrets to your GitHub repository:${NC}"
echo "   Go to: Settings → Secrets and variables → Actions"
echo ""
echo -e "${GREEN}2. Required GitHub Secrets:${NC}"
echo "   AZURE_CLIENT_ID: $CLIENT_ID"
echo ""
echo "   AZURE_TENANT_ID: $TENANT_ID"
echo ""
echo "   AZURE_CLIENT_SECRET: $CLIENT_SECRET"
echo ""
echo "   AZURE_SUBSCRIPTION_ID: $SUBSCRIPTION_ID"
echo ""
echo "   AZURE_WEBAPP_NAME: $APP_SERVICE_NAME"
echo ""
echo "   AZURE_WEBAPP_PUBLISH_PROFILE:"
echo "   (Copy the content from publish-profile.xml)"
echo ""
echo -e "${GREEN}3. Run the infrastructure deployment workflow:${NC}"
echo "   Go to: Actions → Deploy Azure Infrastructure → Run workflow"
echo ""
echo -e "${GREEN}4. After infrastructure is deployed, push code to trigger the build and deploy workflow${NC}"
echo ""
echo -e "${GREEN}5. Your app will be available at: https://$APP_SERVICE_URL${NC}"
echo ""
echo -e "${GREEN}6. Cost Information:${NC}"
echo "   - App Service Plan (F1): FREE"
echo "   - Application Insights: FREE (up to 5GB/month)"
echo "   - Total cost: $0/month"
echo ""
echo -e "${GREEN}7. Region: Canada Central${NC}"
echo ""
echo -e "${YELLOW}=============================================${NC}" 