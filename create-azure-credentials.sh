#!/bin/bash

# Replace with your actual values
SUBSCRIPTION_ID="your-subscription-id"
RESOURCE_GROUP="kamalakar-demo-dev"
ACR_NAME="acrkamaldemodev"
AKS_CLUSTER_NAME="kamal-lgb-aks-cluster-dev"

# Login to Azure
az login

# Set subscription
az account set --subscription $SUBSCRIPTION_ID

# Create Service Principal for GitHub Actions
SP_JSON=$(az ad sp create-for-rbac \
  --name "github-actions-lbg-app" \
  --role contributor \
  --scopes /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP \
  --sdk-auth \
  --output json)

echo "Azure Credentials for GitHub Secrets:"
echo "$SP_JSON"

# Get ACR ID
ACR_ID=$(az acr show --name $ACR_NAME --query id --output tsv)

# Assign ACR push role to service principal
SP_APP_ID=$(echo $SP_JSON | jq -r '.clientId')
az role assignment create \
  --assignee $SP_APP_ID \
  --role AcrPush \
  --scope $ACR_ID

echo "ACR Push role assigned to service principal"

# Get AKS credentials
az aks get-credentials \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_CLUSTER_NAME \
  --overwrite-existing

echo "AKS credentials configured"
