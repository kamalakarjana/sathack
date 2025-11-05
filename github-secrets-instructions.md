# GitHub Secrets Required

Add these secrets to your GitHub repository (Settings -> Secrets and variables -> Actions):

## Required Secrets:

1. **AZURE_CREDENTIALS** - The entire JSON output from the service principal creation
2. **AZURE_CLIENT_ID** - The clientId from the JSON
3. **AZURE_CLIENT_SECRET** - The clientSecret from the JSON  
4. **AZURE_SUBSCRIPTION_ID** - Your Azure subscription ID
5. **AZURE_TENANT_ID** - The tenantId from the JSON

## Optional (if referenced elsewhere):

6. **ACR_LOGIN_SERVER** - acrkamaldemodev.azurecr.io
