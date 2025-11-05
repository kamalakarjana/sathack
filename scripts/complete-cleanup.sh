#!/bin/bash
echo "=== COMPLETE CLEANUP SCRIPT ==="

# Get AKS credentials
az aks get-credentials --resource-group kamalakar-demo-dev --name kamal-lgb-aks-cluster-dev --overwrite-existing

echo "1. Deleting Helm releases..."
helm uninstall lbg-app -n lbg-ns --ignore-not-found=true
helm uninstall lbg-app -n default --ignore-not-found=true

echo "2. Deleting namespace..."
kubectl delete namespace lbg-ns --ignore-not-found=true --timeout=60s

echo "3. Waiting for cleanup..."
sleep 30

echo "4. Force deleting namespace if still exists..."
if kubectl get namespace lbg-ns &> /dev/null; then
  echo "Namespace still exists, forcing deletion..."
  kubectl patch namespace lbg-ns -p '{"metadata":{"finalizers":[]}}' --type=merge
  kubectl delete namespace lbg-ns --force --grace-period=0
  sleep 20
fi

echo "5. Checking ACR images..."
az acr repository list --name acrkamaldemodev.azurecr.io

echo "=== CLEANUP COMPLETED ==="
