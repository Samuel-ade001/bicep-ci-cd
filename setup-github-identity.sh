#!/bin/bash

set -e

APP_NAME="github-sampleapp-bicep"
SUBSCRIPTION_ID="87f9d502-d8bd-4f58-be1a-32a365b439c9"
RESOURCE_GROUP="rg-sampleapp-dev-eastus"

# 1. Set subscription
az account set \
  --subscription "$SUBSCRIPTION_ID"

# 2. Create Microsoft Entra application
APP_ID=$(az ad app create \
  --display-name "$APP_NAME" \
  --query appId \
  --output tsv)

echo "Application Client ID: $APP_ID"

# 3. Create service principal
az ad sp create \
  --id "$APP_ID"

# 4. Get resource group ID
RESOURCE_GROUP_ID=$(az group show \
  --name "$RESOURCE_GROUP" \
  --subscription "$SUBSCRIPTION_ID" \
  --query id \
  --output tsv)

echo "Resource Group ID: $RESOURCE_GROUP_ID"

# 5. Assign Contributor role
az role assignment create \
  --assignee "$APP_ID" \
  --role "Contributor" \
  --scope "$RESOURCE_GROUP_ID"

echo "Contributor role assigned successfully."

# 6. Get tenant ID
TENANT_ID=$(az account show \
  --query tenantId \
  --output tsv)

echo ""
echo "GitHub configuration:"
echo "AZURE_CLIENT_ID=$APP_ID"
echo "AZURE_TENANT_ID=$TENANT_ID"
echo "AZURE_SUBSCRIPTION_ID=$SUBSCRIPTION_ID"
echo "AZURE_RESOURCE_GROUP=$RESOURCE_GROUP"