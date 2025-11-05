#!/bin/bash
echo "=== DEPLOYMENT VERIFICATION SCRIPT ==="

# Get AKS credentials
az aks get-credentials --resource-group kamalakar-demo-dev --name kamal-lgb-aks-cluster-dev --overwrite-existing

echo "1. Checking namespace..."
kubectl get namespace lbg-ns

echo "2. Checking all resources..."
kubectl get all -n lbg-ns

echo "3. Checking pods status..."
kubectl get pods -n lbg-ns -o wide

echo "4. Checking pod logs..."
for pod in $(kubectl get pods -n lbg-ns -o name); do
  echo "=== Logs for $pod ==="
  kubectl logs -n lbg-ns $pod --tail=10
done

echo "5. Checking services..."
kubectl get svc -n lbg-ns

echo "6. Checking ingress..."
kubectl get ingress -n lbg-ns

echo "7. Checking ACR images..."
az acr repository list --name acrkamaldemodev.azurecr.io

echo "=== VERIFICATION COMPLETED ==="
