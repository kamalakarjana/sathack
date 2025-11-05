#!/bin/bash
echo "=== COMPLETE CLEANUP ==="

# Get AKS credentials
az aks get-credentials --resource-group kamalakar-demo-dev --name kamal-lgb-aks-cluster-dev --overwrite-existing

echo "1. Deleting resources..."
kubectl delete namespace lbg-ns --ignore-not-found=true --timeout=60s

echo "2. Waiting for cleanup..."
sleep 30

echo "3. Force deleting if needed..."
if kubectl get namespace lbg-ns &> /dev/null; then
  echo "Forcing namespace deletion..."
  kubectl patch namespace lbg-ns -p '{"metadata":{"finalizers":[]}}' --type=merge
  kubectl delete namespace lbg-ns --force --grace-period=0
  sleep 15
fi

echo "4. Checking ACR images..."
az acr repository list --name acrkamaldemodev.azurecr.io

echo "=== CLEANUP COMPLETED ==="
