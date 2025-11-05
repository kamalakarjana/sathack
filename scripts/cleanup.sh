#!/bin/bash
echo "=== Manual Cleanup Script ==="

# Get AKS credentials
az aks get-credentials --resource-group kamalakar-demo-dev --name kamal-lgb-aks-cluster-dev --overwrite-existing

echo "Cleaning up existing resources..."

# Delete Helm releases
helm uninstall lbg-app -n lbg-ns --ignore-not-found=true
helm uninstall lbg-app -n default --ignore-not-found=true

# Delete namespace
kubectl delete namespace lbg-ns --ignore-not-found=true --timeout=30s

# Wait
sleep 20

# Force delete if still exists
if kubectl get namespace lbg-ns &> /dev/null; then
  echo "Forcing namespace deletion..."
  kubectl patch namespace lbg-ns -p '{"metadata":{"finalizers":[]}}' --type=merge
  kubectl delete namespace lbg-ns --force --grace-period=0
  sleep 15
fi

echo "Cleanup completed!"
