#!/bin/bash

echo "=== Final Health Check ==="

# Check endpoints
echo "=== Endpoints Status ==="
kubectl get endpoints -n lbg-ns

echo "=== Services Status ==="
kubectl get svc -n lbg-ns

echo "=== Ingress Status ==="
kubectl get ingress -n lbg-ns

# Test ingress
EXTERNAL_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Testing ingress with IP: $EXTERNAL_IP"

for endpoint in health patients appointments; do
  echo "Testing /$endpoint:"
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" -H "Host: lbg-app.dev.local" http://$EXTERNAL_IP/$endpoint)
  echo "HTTP Status: $STATUS"
done

echo "=== Ingress Controller Logs (last 5 lines) ==="
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller --tail=5
