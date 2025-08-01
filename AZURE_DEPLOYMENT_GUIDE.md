# Azure Deployment Guide

This guide will help you set up Azure infrastructure and deploy the Java application to Azure App Service.

## Prerequisites

1. **Azure CLI** installed and configured
2. **GitHub repository** with the Java application
3. **Azure subscription** with permissions to create resources
4. **Subscription ID**: `4cae711c-2969-439a-b455-19dd1a5693eb`

## Step 1: Set Up Azure Infrastructure

### Option A: Using the Setup Script (Recommended)

#### For Windows (PowerShell):
```powershell
# Navigate to the project directory
cd C:\Sandbox\sample-actions-demo

# Run the setup script (will deploy to Canada Central)
.\scripts\setup-azure.ps1
```

#### For Linux/Mac (Bash):
```bash
# Navigate to the project directory
cd /path/to/sample-actions-demo

# Make the script executable
chmod +x scripts/setup-azure.sh

# Run the setup script (will deploy to Canada Central)
./scripts/setup-azure.sh
```

### Option B: Manual Setup

#### 1. Login to Azure
```bash
az login
```

#### 2. Set Subscription
```bash
az account set --subscription 4cae711c-2969-439a-b455-19dd1a5693eb
```

#### 3. Create Resource Group
```bash
az group create --name rg-java-sample-app --location "Canada Central"
```

#### 4. Deploy Infrastructure
```bash
az deployment group create \
    --resource-group rg-java-sample-app \
    --template-file infrastructure/main.bicep \
    --parameters resourceGroupName=rg-java-sample-app \
    --parameters appServiceName=app-java-sample \
    --parameters location="Canada Central"
```

#### 5. Create Service Principal
```bash
az ad sp create-for-rbac \
    --name github-actions-java-sample \
    --role contributor \
    --scopes /subscriptions/4cae711c-2969-439a-b455-19dd1a5693eb/resourceGroups/rg-java-sample-app \
    --sdk-auth
```

#### 6. Get Publish Profile
```bash
az webapp deployment list-publishing-profiles \
    --name app-java-sample \
    --resource-group rg-java-sample-app \
    --xml > publish-profile.xml
```

## Step 2: Configure GitHub Secrets

### Required Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions

#### 1. AZURE_CLIENT_ID
- **Value**: The client ID from the managed identity
- **Example**: `12345678-1234-1234-1234-123456789012`

#### 2. AZURE_TENANT_ID
- **Value**: The tenant ID from your Azure subscription
- **Example**: `87654321-4321-4321-4321-210987654321`

#### 3. AZURE_SUBSCRIPTION_ID
- **Value**: Your Azure subscription ID
- **Example**: `4cae711c-2969-439a-b455-19dd1a5693eb`

#### 4. AZURE_WEBAPP_NAME
- **Value**: `app-java-sample` (or your custom App Service name)

#### 5. AZURE_WEBAPP_PUBLISH_PROFILE
- **Value**: The entire content of the `publish-profile.xml` file

### Authentication Method

This setup uses **Federated Identity** (OIDC) which is more secure than service principal secrets:
- No secrets to store or rotate
- Automatic token exchange
- Enhanced security

### How to Add Secrets

1. Go to your GitHub repository
2. Click "Settings" tab
3. Click "Secrets and variables" → "Actions"
4. Click "New repository secret"
5. Add each secret with the appropriate name and value

## Step 3: Deploy Infrastructure (Optional)

If you want to use the GitHub Actions workflow to deploy infrastructure:

1. Go to your GitHub repository → Actions
2. Click "Deploy Azure Infrastructure"
3. Click "Run workflow"
4. Fill in the parameters:
   - **Environment**: dev
   - **Location**: Canada Central
   - **App Service Name**: app-java-sample
5. Click "Run workflow"

## Step 4: Deploy the Application

### Automatic Deployment

Once the secrets are configured, the application will automatically deploy when you:

1. Push code to the `main` or `master` branch
2. The workflow will:
   - Build the Java application
   - Run tests
   - Deploy to Azure App Service

### Manual Deployment

You can also trigger deployment manually:

1. Go to your GitHub repository → Actions
2. Click "Build and Deploy Java Application"
3. Click "Run workflow"

## Step 5: Verify Deployment

### Check Application Status

1. **Azure Portal**:
   - Go to Azure Portal → App Services
   - Find your App Service (`app-java-sample`)
   - Check the URL and status

2. **Application Endpoints**:
   - Home: `https://your-app-service.azurewebsites.net/`
   - Health: `https://your-app-service.azurewebsites.net/health`
   - Info: `https://your-app-service.azurewebsites.net/info`

### Test the Application

```bash
# Test the home endpoint
curl https://your-app-service.azurewebsites.net/

# Test the health endpoint
curl https://your-app-service.azurewebsites.net/health

# Test with a name parameter
curl "https://your-app-service.azurewebsites.net/hello?name=YourName"
```

## Infrastructure Details

### What Gets Created

1. **Resource Group**: `rg-java-sample-app`
2. **App Service Plan**: `asp-java-sample` (F1 tier - FREE)
3. **App Service**: `app-java-sample`
4. **Application Insights**: `ai-app-java-sample` (FREE)

### Configuration

- **Java Version**: 17
- **Runtime**: Linux
- **SKU**: F1 (Free tier)
- **Location**: Canada Central
- **Environment**: Development-ready with monitoring
- **Cost**: $0/month

## Troubleshooting

### Common Issues

#### 1. Azure CLI Not Installed
```bash
# Install Azure CLI
# Windows: Download from https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
# macOS: brew install azure-cli
# Linux: curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

#### 2. Permission Denied
```bash
# Check your Azure role assignments
az role assignment list --assignee your-email@domain.com

# Request contributor access to the subscription
```

#### 3. App Service Name Already Exists
```bash
# Use a unique name
az webapp show --name your-unique-name --resource-group rg-java-sample-app

# Or delete the existing one
az webapp delete --name existing-name --resource-group rg-java-sample-app
```

#### 4. Deployment Fails
- Check that all GitHub secrets are correctly configured
- Verify the App Service exists and is running
- Check the workflow logs for specific error messages

### Debugging Steps

1. **Check Azure Resources**:
   ```bash
   az resource list --resource-group rg-java-sample-app
   ```

2. **Check App Service Logs**:
   ```bash
   az webapp log tail --name app-java-sample --resource-group rg-java-sample-app
   ```

3. **Check GitHub Actions Logs**:
   - Go to Actions → Your workflow → View logs
   - Look for specific error messages

## Cost Optimization

### Current Configuration
- **App Service Plan**: F1 (Free) - $0/month
- **Application Insights**: Free tier included (up to 5GB/month)

### Free Tier Limitations
- **F1 App Service**: 
  - 1 GB RAM
  - 60 minutes/day CPU time
  - 1 GB storage
  - Shared infrastructure
- **Application Insights**: 
  - 5 GB data ingestion/month
  - 1 GB data retention

### Scaling Options (When Ready for Production)
- **Development**: F1 (Free) - $0/month
- **Production**: S1 (Standard) - $73/month
- **High Traffic**: P1V2 (Premium) - $146/month

### Cost Optimization Tips
1. Use F1 tier for development and testing
2. Monitor usage to stay within free limits
3. Use Azure Dev/Test subscription benefits
4. Monitor usage with Application Insights

## Security Considerations

1. **Service Principal**: Limited to resource group scope
2. **Publish Profile**: Contains deployment credentials
3. **Environment Variables**: No sensitive data in code
4. **HTTPS**: Enabled by default on App Service

## Next Steps

After successful deployment:

1. **Monitor the Application**:
   - Set up alerts in Application Insights
   - Monitor performance metrics

2. **Scale the Application**:
   - Configure auto-scaling rules
   - Set up staging environments

3. **Customize the Deployment**:
   - Add custom domain
   - Configure SSL certificates
   - Set up CDN

4. **Add More Features**:
   - Database integration
   - Authentication
   - API management 