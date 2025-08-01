# Azure App Service Deployment Setup

This guide will help you set up the required secrets and variables for deploying the Java application to Azure App Service using the reusable workflows.

## Required GitHub Secrets

The workflow requires the following secrets to be configured in your GitHub repository:

### 1. Azure Authentication Secrets

These secrets are required for Azure authentication and security checks:

- `AZURE_TENANT_ID`: Your Azure AD tenant ID
- `AZURE_SUBSCRIPTION_ID`: Your Azure subscription ID
- `KEY_VAULT_NAME`: Your Azure Key Vault name
- `AZURE_CLIENT_ID`: Your Azure application client ID
- `AZURE_CLIENT_SECRET`: Your Azure application client secret

### 2. Azure App Service Secrets

These secrets are required for deploying to Azure App Service:

- `AZURE_WEBAPP_NAME`: Your Azure App Service name
- `AZURE_WEBAPP_PUBLISH_PROFILE`: Your Azure App Service publish profile

## How to Set Up Secrets

1. Go to your GitHub repository
2. Click on "Settings" tab
3. In the left sidebar, click on "Secrets and variables" → "Actions"
4. Click "New repository secret" for each required secret
5. Add each secret with the appropriate name and value

## Getting Azure Values

### Azure Tenant ID
- Go to Azure Portal → Azure Active Directory → Overview
- Copy the "Tenant ID" value

### Azure Subscription ID
- Go to Azure Portal → Subscriptions
- Copy the "Subscription ID" value

### Key Vault Name
- Go to Azure Portal → Key Vaults
- Copy the name of your Key Vault

### Azure Client ID and Secret
1. Go to Azure Portal → Azure Active Directory → App registrations
2. Create a new registration or use an existing one
3. Copy the "Application (client) ID"
4. Go to "Certificates & secrets" → "New client secret"
5. Copy the generated secret value

### Azure App Service Name
- Go to Azure Portal → App Services
- Copy the name of your App Service

### Azure App Service Publish Profile
1. Go to Azure Portal → App Services → Your App Service
2. Click on "Get publish profile"
3. Download the publish profile file
4. Copy the entire content of the file

## Creating Azure App Service

If you don't have an Azure App Service yet, follow these steps:

### 1. Create App Service Plan
```bash
az appservice plan create \
  --name my-appservice-plan \
  --resource-group my-resource-group \
  --sku B1 \
  --is-linux
```

### 2. Create App Service
```bash
az webapp create \
  --name my-java-app \
  --resource-group my-resource-group \
  --plan my-appservice-plan \
  --runtime "JAVA|17-java17"
```

### 3. Configure Java Settings
```bash
az webapp config set \
  --name my-java-app \
  --resource-group my-resource-group \
  --linux-fx-version "JAVA|17-java17"
```

## Workflow Configuration

The workflow uses a single reusable workflow that handles both building and deploying:

1. **Build and Deploy Job**: Uses the reusable java-reusable.yml workflow
   - Java 17 setup
   - Maven build and test
   - Azure security checks
   - Artifact upload
   - Azure App Service deployment
   - Dev environment
   - Azure authentication

## Testing the Setup

Once you've configured all the secrets:

1. Push your code to the `main` or `master` branch
2. Go to the "Actions" tab in your GitHub repository
3. You should see the "Build and Deploy Java Application" workflow running
4. The workflow will:
   - Set up Java 17
   - Run security checks using Azure authentication
   - Build the application using Maven
   - Run unit tests
   - Upload build artifacts
   - Deploy to Azure App Service (all in one workflow)

## Troubleshooting

### Common Issues

1. **Authentication Failed**
   - Verify all Azure secrets are correctly configured
   - Check that the Azure app registration has the necessary permissions
   - Ensure the Key Vault exists and is accessible

2. **Deployment Failed**
   - Verify `AZURE_WEBAPP_NAME` is correct
   - Check that `AZURE_WEBAPP_PUBLISH_PROFILE` contains valid content
   - Ensure the App Service exists and is running

3. **Build Failed**
   - Check that the Maven wrapper exists (`mvnw`)
   - Verify the `pom.xml` is correctly configured
   - Ensure all dependencies are available

### Debugging Steps

1. **Check Workflow Logs**
   - Go to Actions → Your workflow → View logs
   - Look for specific error messages

2. **Verify Secrets**
   - Go to Settings → Secrets and variables → Actions
   - Ensure all required secrets are present

3. **Test Locally**
   - Run `./mvnw clean package` locally
   - Verify the application builds successfully

## Environment Variables

The workflow uses these environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `JAVA_VERSION` | Java version to use | 17 |
| `BUILD_TOOL` | Build tool (maven/gradle) | maven |
| `ENVIRONMENT` | Target environment | dev |
| `DEPLOYMENT_TARGET` | Azure deployment target | app-service |

## Security Features

The reusable workflows include:

- **Azure Authentication**: Secure authentication using Azure AD
- **Key Vault Integration**: Secure secret management
- **JIT Access**: Just-in-time access for enhanced security
- **Environment Protection**: Environment-specific deployments

## Next Steps

After successful deployment:

1. **Monitor the Application**
   - Check the App Service logs in Azure Portal
   - Monitor the application health endpoints

2. **Scale the Application**
   - Configure auto-scaling rules
   - Set up monitoring and alerts

3. **Customize the Deployment**
   - Modify the environment variables
   - Add custom deployment scripts
   - Configure staging environments 